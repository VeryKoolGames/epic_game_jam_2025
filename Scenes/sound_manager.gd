extends Node

@export var no_sounds: Array[AudioStreamPlayer2D]
@export var yes_sounds: Array[AudioStreamPlayer2D]
@export var button_sounds: Array[AudioStreamPlayer2D]
@export var positive_feedback_sounds: Array[AudioStreamPlayer2D]
@export var pointing_sounds: Array[AudioStreamPlayer2D]
@export var throw_sounds: Array[AudioStreamPlayer2D]
@export var bad_alarm: AudioStreamPlayer2D
@export var lever_sound: AudioStreamPlayer2D

@rpc("any_peer")
func _play_no_sound_rpc():
	_play_random_sound(no_sounds)

@rpc("any_peer")
func _play_yes_sound_rpc():
	_play_random_sound(yes_sounds)

func _play_yes_sound() -> void:
	_play_yes_sound_rpc.rpc()
	_play_random_sound(yes_sounds)

func _play_no_sound() -> void:
	_play_no_sound_rpc.rpc()
	_play_random_sound(no_sounds)

func _play_random_sound(sound_list: Array[AudioStreamPlayer2D]):
	if sound_list.is_empty():
		return
	var random_sound = sound_list[randi_range(0, sound_list.size() - 1)]
	print(random_sound)
	random_sound.play()

@rpc("any_peer")
func _play_button_sound_rpc() -> void:
	_play_random_sound(button_sounds)

func play_button_sound() -> void:
	_play_random_sound(button_sounds)
	_play_button_sound_rpc.rpc()

func play_bad_alarm_sound() -> void:
	if not bad_alarm:
		return
	bad_alarm.play()
	play_bad_alarm_sound_rpc.rpc()

@rpc("any_peer")
func play_bad_alarm_sound_rpc() -> void:
	bad_alarm.play()

@rpc("any_peer")
func play_positive_feedback_sound_rpc() -> void:
	_play_random_sound(positive_feedback_sounds)

func play_positive_feedback_sound() -> void:
	play_positive_feedback_sound_rpc.rpc()
	_play_random_sound(positive_feedback_sounds)

@rpc("any_peer")
func play_pointing_sound_rpc() -> void:
	_play_random_sound(pointing_sounds)

func play_pointing_sound() -> void:	
	play_pointing_sound_rpc.rpc()
	_play_random_sound(pointing_sounds)
	
func play_throw_sounds() -> void:
	_play_random_sound(throw_sounds)

func play_lever_sound() -> void:
	if not lever_sound:
		return
	lever_sound.pitch_scale = randf_range(0.8, 1.2)
	lever_sound.play
