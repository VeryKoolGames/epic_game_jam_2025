extends Node

@export var animation_trees: Array[AnimationTree]

func show_wrong_alarm() -> void:
	for alarm in animation_trees:
		var playback = alarm.get("parameters/playback")
		playback.travel("Alarme_Erreur")

func show_correct_alarm() -> void:
	for alarm in animation_trees:
		var playback = alarm.get("parameters/playback")
		playback.travel("Alarme_Correct")
