extends Node

var number_of_player := 2
var counter_player_finished := 0

func _ready() -> void:
	Events.on_ending_reached.connect(_on_ending_reached)

func _on_ending_reached() -> void:
	counter_player_finished += 1
	if counter_player_finished >= number_of_player:
		print("Game is done")
