extends RigidBody3D
class_name PickUpItem

var last_position := Vector3.ZERO
var target_position := Vector3.ZERO
var lerp_alpha := 0.0
@export var item: ResPickableItem
var player_id := -1

@rpc("any_peer")
func update_item_position(new_pos: Vector3):
	last_position = global_transform.origin
	target_position = new_pos
	lerp_alpha = 0.0

@rpc("any_peer", "call_local")
func _set_multiplayer_authority(id: int):
	set_multiplayer_authority(id)

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		if not freeze and linear_velocity.length() > 0.1:
			update_item_position.rpc(global_transform.origin)
	else:
		lerp_alpha = min(lerp_alpha + delta * 5.0, 1)
		global_transform.origin = last_position.lerp(target_position, lerp_alpha)
		

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("cauldron") and ChallengeManager.can_complete_challenge(player_id):
		if check_if_ingredient_matches(item):
			Events.pick_up_item_dropped_in_cauldron.emit(item)
			scale_down_and_queue_free()
		
func scale_down_and_queue_free() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 0.2)
	tween.tween_callback(func(): self.queue_free())

func check_if_ingredient_matches(ingredient: ResPickableItem) -> bool:
	var current_recipe = RecipeManager.current_recipe
	if not current_recipe or not current_recipe.ingredients:
		return false

	for ingr in current_recipe.ingredients:
		if ingr.type == ingredient.type:
			return true
	return false
