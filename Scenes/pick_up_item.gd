extends RigidBody3D
class_name PickUpItem

var last_position := Vector3.ZERO
var target_position := Vector3.ZERO
var lerp_alpha := 0.0
@export var item: ResPickableItem
@export var mesh: MeshInstance3D
var player_id := -1
var original_position := Vector3.ZERO
var recipe_manager: RecipeManager

func _ready() -> void:
	recipe_manager = get_parent().get_parent()
	original_position = global_transform.origin
	
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
		recipe_manager.try_ingredient(item)
		scale_down_and_queue_free_rpc.rpc()
		scale_down_and_queue_free()

@rpc("any_peer")
func scale_down_and_queue_free_rpc() -> void:
	scale_down_and_queue_free()

func scale_down_and_queue_free() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 0.2)
	tween.tween_callback(make_item_respawn)

func make_item_respawn() -> void:
	var tween = create_tween()
	global_transform.origin = original_position
	tween.tween_property(self, "scale", Vector3(1, 1, 1), 0.2)

func activate_outline() -> void:
	return
	mesh.material_overlay.grow = true

func deactivate_outline() -> void:
	return
	mesh.material_overlay.grow = false
