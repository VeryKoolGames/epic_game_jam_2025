extends TextureRect

@export var potential_numbers: Array[Texture2D]

func _ready() -> void:
	texture = potential_numbers[ChallengeManager.challenge_counter]
