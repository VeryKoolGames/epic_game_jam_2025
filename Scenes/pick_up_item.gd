extends Node3D
class_name PickUpItem

var last_position := Vector3.ZERO
var target_position := Vector3.ZERO
var lerp_alpha := 0.0

@rpc("any_peer")
func update_item_position(new_pos: Vector3):
	last_position = global_transform.origin
	target_position = new_pos
	lerp_alpha = 0.0

@rpc("any_peer", "call_local")
func _set_multiplayer_authority(id: int):
	set_multiplayer_authority(id)

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		lerp_alpha = min(lerp_alpha + delta * 5.0, 1)
		global_transform.origin = last_position.lerp(target_position, lerp_alpha)
