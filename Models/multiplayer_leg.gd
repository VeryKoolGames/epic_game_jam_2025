extends Node3D

var last_rotation: Vector3 = Vector3.ZERO
var target_rotation: Vector3 = Vector3.ZERO
var rotation_lerp_alpha: float = 0.0
var previous_rotation: Vector3 = Vector3.ZERO


@rpc("any_peer")
func update_body_rotation(new_rot: Vector3) -> void:
	last_rotation = rotation
	target_rotation = new_rot
	rotation_lerp_alpha = 0.0

func _process(delta: float) -> void:
	if not owner.is_multiplayer_authority():
		rotation_lerp_alpha = min(rotation_lerp_alpha + delta * 5.0, 1.0)
		rotation = last_rotation.lerp(target_rotation, rotation_lerp_alpha)
		return
	if rotation.distance_to(previous_rotation) > 0.01:
		update_body_rotation.rpc(rotation)
		previous_rotation = rotation
