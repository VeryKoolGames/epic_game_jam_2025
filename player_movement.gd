extends Node3D
class_name Player

@onready var state_machine = $StateMachine
@export var animation_tree_arms: AnimationTree
@export var player_speed: float = 5.0
@onready var lower_body = $Character/Bassin
@onready var body = $Character/Haut
var last_position := Vector3.ZERO
var target_position := Vector3.ZERO
var lerp_alpha := 0.0
var rotation_lerp_alpha := 0.0
var last_rotation := Vector3.ZERO
var target_rotation := Vector3.ZERO
var lower_body_rotation_lerp_alpha := 0.0
var last_lower_body_rotation := Vector3.ZERO
var target_lower_body_rotation := Vector3.ZERO
var is_pointing := false
var is_holding := false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

@rpc("any_peer")
func update_position(new_pos: Vector3):
	last_position = global_transform.origin
	target_position = new_pos
	lerp_alpha = 0.0

@rpc("any_peer")
func update_body_rotation(new_rot: Vector3):
	last_rotation = body.rotation
	target_rotation = new_rot
	rotation_lerp_alpha = 0.0

@rpc("any_peer")
func update_lower_body_rotation(new_rot: Vector3):
	last_lower_body_rotation = lower_body.rotation
	target_lower_body_rotation = new_rot
	lower_body_rotation_lerp_alpha = 0.0

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event.is_action_released("point") and not is_pointing and not is_holding:
		animation_tree_arms.set("parameters/conditions/Pointing", true)
		await get_tree().create_timer(0.5).timeout
		is_pointing = true
	elif event.is_action_released("point") and is_pointing and not is_holding:
		print("Stopping to point")
		animation_tree_arms.set("parameters/conditions/idle", true)
		animation_tree_arms.set("parameters/conditions/Pointing", false)
		await get_tree().create_timer(0.5).timeout
		is_pointing = false

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		lerp_alpha = min(lerp_alpha + delta * 5, 1.0)
		global_transform.origin = last_position.lerp(target_position, lerp_alpha)
	
		rotation_lerp_alpha = min(rotation_lerp_alpha + delta * 5, 1.0)
		body.rotation = last_rotation.lerp(target_rotation, rotation_lerp_alpha)
		lower_body_rotation_lerp_alpha = min(lower_body_rotation_lerp_alpha + delta * 5, 1.0)
		lower_body.rotation = last_lower_body_rotation.lerp(target_lower_body_rotation, lower_body_rotation_lerp_alpha)
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
		state_machine._transition_to_next_state("Moving")
		direction = direction.normalized() * player_speed * delta
		var new_position: Vector3 = global_transform.origin + direction
		global_transform.origin = new_position
		var movement_angle = atan2(direction.x, direction.z)
		lower_body.rotation.y = movement_angle
	else:
		state_machine._transition_to_next_state("Idle")
	update_position.rpc(global_transform.origin)
	update_body_rotation.rpc(body.rotation)
	update_lower_body_rotation.rpc(lower_body.rotation)
