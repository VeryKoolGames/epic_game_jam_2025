extends Challenge
class_name PressurePlateChallenge

@export var pressure_plate_counter := 4
var current_pressure_plate_counter := 0

func create_challenge() -> Challenge:
	return self

func on_pressure_plate_activated() -> void:
	current_pressure_plate_counter += 1
	if current_pressure_plate_counter >= pressure_plate_counter:
		get_parent().on_final_challenge_completed()

func on_pressure_plate_deactivated() -> void:
	current_pressure_plate_counter -= 1
