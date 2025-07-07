extends Challenge
class_name RecipeManager

@export var available_ingredients: Array[ResPickableItem]
@export var max_ingredients_per_recipe: int = 3
var current_recipe: Dictionary = {}
var copy_recipe: Dictionary = {}

@rpc("authority", "call_local")
func sync_recipes(recipe: Dictionary) -> void:
	current_recipe = recipe

@rpc("any_peer")
func share_new_recipe(recipe: Dictionary) -> void:
	current_recipe = recipe.duplicate(true)
	copy_recipe = recipe.duplicate(true)

func create_challenge() -> Challenge:
	var recipe = _create_random_recipe()
	current_recipe = recipe.duplicate(true)
	copy_recipe = recipe.duplicate(true)
	share_new_recipe.rpc(recipe)
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
	if not current_recipe or not current_recipe.ingredients:
		return
	for ingr in current_recipe.ingredients:
		if int(ingr.type) == int(item.type):
			current_recipe.ingredients.erase(ingr)
			if current_recipe.ingredients.is_empty():
				get_parent().on_success_challenge()
				get_parent().create_challenge()
			return
	reset_recipe()
	return

func reset_recipe() -> void:
	get_parent().on_fail_challenge()
#	share_new_recipe.rpc(copy_recipe)
