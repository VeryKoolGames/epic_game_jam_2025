extends Node

var can_use_emotes := true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("no") and can_use_emotes:
		SoundManager._play_no_sound()
	if event.is_action_pressed("yes") and can_use_emotes:
		SoundManager._play_yes_sound()

func emote_cooldown() -> void:
	can_use_emotes = false
	await get_tree().create_timer(5).timeout
	can_use_emotes = true
