extends Challenge
class_name ButtonManager

var correct_combination: Array[int]
var combination_copy: Array[int]
var current_number_of_guess := 0
@export var max_number_combination := 3

func _ready() -> void:
	Events.try_combination.connect(try_combination)

@rpc("any_peer")
func share_new_challenge() -> void:
	Events.new_buttons_challenge_generated.emit(correct_combination)

@rpc("any_peer")
func share_combination(_correct_combination: Array[int]) -> void:
	correct_combination = _correct_combination.duplicate(true)
	print("Setting correct combination for ", multiplayer.get_unique_id())

func create_challenge() -> Challenge:
	create_random_combination()
	Events.new_buttons_challenge_generated.emit(correct_combination)
	share_new_challenge.rpc()
	share_combination.rpc(correct_combination)
	return self

func create_random_combination() -> void:
	var pool: Array[int] = [0, 1, 2, 3, 4]
	pool.shuffle()

	var copy: Array[int] = []
	for i in pool:
		copy.append(i)

	correct_combination = copy
	correct_combination.remove_at(0)

	if randi() % 20 < 10:
		correct_combination.remove_at(0)

	combination_copy = correct_combination.duplicate(true)

func try_combination(try: int) -> void:
	if correct_combination.is_empty():
		return
	var res := correct_combination[current_number_of_guess] == try
	if not res:
		reset_combination()
	else:
		current_number_of_guess += 1
		correct_combination.erase(try)
	if correct_combination.is_empty():
		Events.on_challenge_completed.emit()

func reset_combination() -> void:
	Events.wrong_button_pressed.emit()
	correct_combination = combination_copy.duplicate(true)
