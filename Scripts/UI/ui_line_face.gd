extends TextureRect

@export var face_player_one: Texture2D
@export var face_player_two: Texture2D

func _ready() -> void:
	if ChallengeManager.player_that_generated_quest == 1:
		texture = face_player_one
	else:
		texture = face_player_two
