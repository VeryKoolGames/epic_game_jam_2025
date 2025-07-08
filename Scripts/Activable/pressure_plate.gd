extends Node3D

@onready var animation_player = $AnimationPlayer
@export var pressure_plate_manager: PressurePlateChallenge
var is_pressed := false
var is_activated := false
var pressed_timer := 0.0
var pressed_threshold := 0.5
var number_of_item_on := 0

func _process(_delta: float) -> void:
	if not is_pressed or is_activated:
		return
	pressed_timer += 0.1
	if pressed_timer >= pressed_threshold:
		_activate_pressure_plate()

#func _on_area_3d_area_entered(area: Area3D) -> void:
	#if area.owner.is_in_group("pickup") or area.owner.is_in_group("player"):
		#is_pressed = true
		#number_of_item_on += 1

func _activate_pressure_plate() -> void:
	is_activated = true
	animation_player.play("activate")
	pressure_plate_manager.on_pressure_plate_activated()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.get_groups())
	if body.is_in_group("pickup") or body.is_in_group("player"):
		print("Came in")
		is_pressed = true
		number_of_item_on += 1

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("pickup") or body.is_in_group("player"):
		print("Came out")
		number_of_item_on -= 1
		if number_of_item_on != 0:
			return
		is_pressed = false
		if is_activated:
			pressure_plate_manager.on_pressure_plate_deactivated()
			animation_player.play_backwards("activate")
		is_activated = false
		pressed_timer = 0.0
