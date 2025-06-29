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

@rpc("any_peer")
func _reset_count():
	current_number_of_guess = 0
	
func create_challenge() -> Challenge:
	create_random_combination()
	Events.new_buttons_challenge_generated.emit(correct_combination)
	share_new_challenge.rpc()
	share_combination.rpc(correct_combination)
	_reset_count.rpc()
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

func try_combination(try: int, player_id: int) -> void:
	if not ChallengeManager.can_complete_challenge(player_id):
		return
	
	if correct_combination.is_empty():
		return
	var res := correct_combination[current_number_of_guess] == try
	if not res:
		reset_combination()
	else:
		current_number_of_guess += 1
	if current_number_of_guess > 2 and current_number_of_guess == correct_combination.size():
		SoundManager.play_positive_feedback_sound()
		get_parent().create_challenge()

func reset_combination() -> void:
	SoundManager.play_bad_alarm_sound()
	Events.wrong_button_pressed.emit()
	current_number_of_guess = 0
