extends Challenge
class_name ButtonManager

var correct_combination: Array[bool]
@export var max_number_combination := 3

func create_challenge() -> Challenge:
	create_random_combination()
	return self

func create_random_combination() -> void:
	for i in range(0, max_number_combination):
		correct_combination[i] = true if (randi() % 20) % 2 == 0 else false
