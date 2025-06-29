extends Challenge
class_name RecipeManager

@export var available_ingredients: Array[ResPickableItem]
@export var max_ingredients_per_recipe: int = 3
var current_recipe: Dictionary = {}
var copy_recipe: Dictionary = {}

@rpc("authority", "call_local")
func sync_recipes(recipe: Dictionary) -> void:
	current_recipe = recipe
	Events.new_recipe_generated.emit(recipe)

@rpc("any_peer")
func add_new_recipe(recipe: Dictionary) -> void:
	Events.new_recipe_generated.emit(recipe)

func create_challenge() -> Challenge:
	var recipe = _create_random_recipe()
	current_recipe = recipe.duplicate(true)
	copy_recipe = recipe.duplicate(true)
	add_new_recipe.rpc(recipe)
	return self

func get_current_recipe():
	return current_recipe

func _create_random_recipe() -> Dictionary:
	var recipe = {
		 "ingredients": [],
	 }

	var selected_ingredients = available_ingredients.duplicate(true)
	selected_ingredients.shuffle()

	var num_ingredients = min(randi_range(2, max_ingredients_per_recipe), selected_ingredients.size() - 1)
	for i in range(num_ingredients):
		var ingredient = selected_ingredients[i]
		recipe.ingredients.append({
			"type": ingredient.type,
		})

	return recipe

func try_ingredient(item: ResPickableItem) -> void:
	print("Trying ingredient:", item.type)
	print("I am player ID:", multiplayer.get_unique_id())
	if not current_recipe or not current_recipe.ingredients:
		return
	print(current_recipe.ingredients)
	for ingr in current_recipe.ingredients:
		if int(ingr.type) == int(item.type):
			print("Ingredient matched:", ingr.type, "with item type:", item.type)
			current_recipe.ingredients.erase(ingr)
			if current_recipe.ingredients.is_empty():
				SoundManager.play_positive_feedback_sound()
				Events.on_challenge_completed.emit()
			return
	reset_recipe()
	return

func reset_recipe() -> void:
	SoundManager.play_bad_alarm_sound()
	print("reseting recipe")
	print("before", current_recipe)
	current_recipe = copy_recipe.duplicate(true)
	print("after", current_recipe)
