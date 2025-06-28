extends Challenge
class_name RecipeManager

@export var available_ingredients: Array[ResPickableItem]
@export var max_ingredients_per_recipe: int = 3
var current_recipe: Dictionary = {}
var copy_recipe: Dictionary = {}

func _ready() -> void:
	Events.pick_up_item_dropped_in_cauldron.connect(_remove_ingredient)

@rpc("authority", "call_local")
func sync_recipes(recipe: Dictionary) -> void:
	current_recipe = recipe
	Events.new_recipe_generated.emit(recipe)

@rpc("authority", "call_local")
func add_new_recipe(recipe: Dictionary) -> void:
	Events.new_recipe_generated.emit(recipe)

@rpc("any_peer")
func complete_recipe() -> void:
	if not multiplayer.is_server():
		return
	current_recipe.clear()
	
	var challenge_manager = get_parent() as ChallengeManager
	challenge_manager.add_challenge()

func create_challenge() -> Challenge:
	var recipe = _create_random_recipe()
	current_recipe = recipe
	copy_recipe = recipe
	add_new_recipe.rpc(recipe)
	return self

func get_current_recipe():
	return current_recipe

func _create_random_recipe() -> Dictionary:
	var recipe = {
		 "ingredients": [],
	 }

	var selected_ingredients = available_ingredients.duplicate()
	selected_ingredients.shuffle()

	var num_ingredients = min(randi_range(2, max_ingredients_per_recipe), selected_ingredients.size() - 1)
	for i in range(num_ingredients):
		var ingredient = selected_ingredients[i]
		recipe.ingredients.append({
			"type": ingredient.type,
			"sprite_path": ingredient.sprite.resource_path if ingredient.sprite else ""
		})

	return recipe

func _remove_ingredient(ingredient: ResPickableItem) -> void:
	if not current_recipe or not current_recipe.ingredients:
		return
	
	for ingr in current_recipe.ingredients:
		if ingr.type == ingredient.type:
			current_recipe.ingredients.erase(ingr)
			break
	if current_recipe.is_empty():
		print("Recipe completed!")
	print("Current recipe after removal:", current_recipe)

func try_ingredient(item: ResPickableItem) -> void:
	print("Trying ingredient: ", item.type)
	if not current_recipe or not current_recipe.ingredients:
		return
	print(current_recipe.ingredients)
	for ingr in current_recipe.ingredients:
		if ingr.type == item.type:
			current_recipe.ingredients.erase(ingr)
			print("erased done: left:", current_recipe)
			if current_recipe.ingredients.is_empty():
				print("Recipe completed!")
			return
	reset_recipe()
	return

func reset_recipe() -> void:
	current_recipe = copy_recipe
