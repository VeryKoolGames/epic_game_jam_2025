extends Control

@onready var label = $Label

func on_challenge_created(_dict: Dictionary) -> void:
	label.text = "Challenge cooking chosen"
