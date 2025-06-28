extends Challenge
class_name RecipeManager

@export var available_ingredients: Array[ResPickableItem]
@export var max_ingredients_per_recipe: int = 3
var current_recipe: Dictionary = {}

@rpc("authority", "call_local")
func sync_recipes(recipe: Dictionary) -> void:
	current_recipe = recipe
	print("Recipes synchronized: ", recipe)

@rpc("authority", "call_local")
func add_new_recipe(recipe: Dictionary) -> void:
	Events.new_recipe_generated.emit(recipe)
	print("New recipe added: ", recipe)

@rpc("any_peer")
func complete_recipe() -> void:
	if not multiplayer.is_server():
		return
	current_recipe.clear()
	
	var challenge_manager = get_parent() as ChallengeManager
	challenge_manager.add_challenge()

func generate_initial_recipe() -> void:
	current_recipe = _create_random_recipe()

	sync_recipes.rpc(current_recipe)

func _generate_new_recipe() -> void:
	var recipe = _create_random_recipe()
	add_new_recipe.rpc(recipe)

func get_current_recipe():
	return current_recipe

func _create_random_recipe() -> Dictionary:
	var recipe = {
		"ingredients": [],
	}

	var num_ingredients = randi_range(2, max_ingredients_per_recipe)
	var selected_ingredients = available_ingredients.duplicate()
	selected_ingredients.shuffle()

	for i in range(num_ingredients):
		var ingredient_data = {
			"type": selected_ingredients[i].type,
			"sprite_path": selected_ingredients[i].sprite.resource_path if selected_ingredients[i].sprite else ""
		}
		recipe.ingredients.append(ingredient_data)

	return recipe

func check_if_ingredient_matches(ingredient: ResPickableItem) -> bool:
	if not current_recipe or not current_recipe.ingredients:
		return false

	for ingr in current_recipe.ingredients:
		if ingr.type == ingredient.type:
			current_recipe.ingredients.erase(ingr)
			if not current_recipe.ingredients:
				complete_recipe.rpc()
			else:
				sync_recipes.rpc(current_recipe)
			return true
	return false
