extends CharacterBody3D
class_name Player
@onready var state_machine = $StateMachine
@export var animation_tree_arms: AnimationTree
@export var player_speed: float = 15.0
@onready var lower_body = $Character/Bassin
@onready var body = $Character/Haut
@onready var arm = $Character/Haut/Bras/Bras1
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
var position_initialized := false  # Add this flag
var can_interact := true
var arm_state_machine: StateMachine
var can_point := true
var can_move := true
@export var pickup_manager: Node

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func release_item() -> void:
	pickup_manager.release_item()

func _ready() -> void:
	Events.on_map_opened.connect(on_start_reading_map)
	Events.on_map_closed.connect(on_stop_reading_map)
	arm_state_machine = animation_tree_arms.get_child(0)
	if multiplayer.get_unique_id() == 1:
		global_position.x -= 15
	else:
		global_position.x += 15
		global_position.y -= 2

func on_start_reading_map() -> void:
	can_move = false
	arm_state_machine._transition_to_next_state("Reading")

func on_stop_reading_map() -> void:
	can_move = true
	arm_state_machine._transition_to_next_state("Idle")

@rpc("any_peer")
func update_position(new_pos: Vector3):
	if multiplayer.get_unique_id() == name.to_int():
		return
	last_position = global_transform.origin
	target_position = new_pos
	lerp_alpha = 0.0

@rpc("any_peer")
func update_body_rotation(new_rot: Vector3):
	if multiplayer.get_unique_id() == name.to_int():
		return
	last_rotation = body.rotation
	target_rotation = new_rot
	rotation_lerp_alpha = 0.0

@rpc("any_peer")
func sync_pointing_state(pointing: bool):
	is_pointing = pointing

func switch_to_holding_state() -> void:
	is_holding = true
	is_pointing = false
	arm_state_machine._transition_to_next_state("Holding")

@rpc("any_peer")
func update_lower_body_rotation(new_rot: Vector3):
	if multiplayer.get_unique_id() == name.to_int():
		return
	last_lower_body_rotation = lower_body.rotation
	target_lower_body_rotation = new_rot
	lower_body_rotation_lerp_alpha = 0.0

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority() or not can_move:
		return
	if event.is_action_pressed("point") and not is_pointing and can_point and not is_holding:
		point_cooldown()
		is_pointing = true
		arm_state_machine._transition_to_next_state("Pointing")
		SoundManager.play_pointing_sound()
	elif event.is_action_pressed("point") and is_pointing and can_point and not is_holding:
		point_cooldown()
		arm_state_machine._transition_to_next_state("Idle")
		is_pointing = false

func point_cooldown() -> void:
	can_point = false
	await get_tree().create_timer(0.5).timeout
	can_point = true

func _process(delta: float) -> void:
	if not can_move:
		return
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
		if not is_holding and not is_pointing:
			arm_state_machine._transition_to_next_state("Moving")
		direction = direction.normalized()
		velocity = direction * player_speed
		move_and_slide()
		var movement_angle = atan2(direction.x, direction.z)
		lower_body.rotation.y = movement_angle
	else:
		if not is_holding and not is_pointing:
			arm_state_machine._transition_to_next_state("Idle")
		state_machine._transition_to_next_state("Idle")
		velocity = Vector3.ZERO

	update_position.rpc(global_transform.origin)
	update_body_rotation.rpc(body.rotation)
	update_lower_body_rotation.rpc(lower_body.rotation)
