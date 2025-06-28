extends Node
class_name ChallengeManager

var challenge_counter := -1
@export var challenge_total: int = 5
@export var challenges: Array[Challenge]
var current_challenge: Challenge

func _ready() -> void:
	for child in get_children():
		if child is Challenge:
			challenges.append(child)

func add_challenge() -> void:
	challenge_counter += 1
	if challenge_counter >= challenge_total:
		print("Game finish")
	current_challenge = challenges[randi_range(0, challenges.size() - 1)].create_challenge()
