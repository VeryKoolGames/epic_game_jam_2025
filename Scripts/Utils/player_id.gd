extends Node3D

var player_id := 1

func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	player_id = MultiplayerManager.player_id
