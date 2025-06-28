extends Node3D

@export var joystick_index: int = 0

const RIGHT_STICK_X := JOY_AXIS_RIGHT_X
const RIGHT_STICK_Y := JOY_AXIS_RIGHT_Y

func _process(delta: float) -> void:
	if not owner.is_multiplayer_authority():
		return
	var x = Input.get_joy_axis(joystick_index, RIGHT_STICK_X)
	var y = Input.get_joy_axis(joystick_index, RIGHT_STICK_Y)

	var deadzone := 0.2
	var input_vector = Vector2(x, y)

	if input_vector.length() < deadzone:
		return

	# Calculate angle and rotate body
	var angle = atan2(-input_vector.x, -input_vector.y)  # In Godot, Y is forward
	var target_rotation = Vector3(0, angle, 0)
	rotation = target_rotation
