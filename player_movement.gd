extends Node3D

@export var player_speed: float = 5.0
var last_position := Vector3.ZERO
var target_position := Vector3.ZERO
var lerp_alpha := 0.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

@rpc("any_peer")
func update_position(new_pos: Vector3):
	last_position = global_transform.origin
	target_position = new_pos
	lerp_alpha = 0.0	

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		lerp_alpha = min(lerp_alpha + delta * 5, 1.0)
		global_transform.origin = last_position.lerp(target_position, lerp_alpha)
		return
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if direction != Vector3.ZERO:
		direction = direction.normalized() * player_speed * delta
		var new_position: Vector3 = global_transform.origin + direction
		global_transform.origin = new_position
		var look_at_target: Vector3 = global_transform.origin + direction
		look_at(look_at_target, Vector3.UP)
		update_position.rpc(global_transform.origin)
