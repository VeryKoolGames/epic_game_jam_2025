extends TextureRect

@export var face_player_one: Texture2D
@export var face_player_two: Texture2D

func _ready() -> void:
	if MultiplayerManager.player_id == 1:
		texture = face_player_one
	else:
		texture = face_player_two
