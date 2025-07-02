extends Node

@export var animation_trees: Array[AnimationTree]
@export var camera: Camera3D
@onready var red_overlay = $Overlay/RedOverlay as ColorRect
@onready var green_overlay = $Overlay/GreenOverlay as ColorRect

func show_wrong_alarm() -> void:
	do_screen_shake_decay()
	show_red_overlay()
	for alarm in animation_trees:
		var playback = alarm.get("parameters/playback")
		playback.travel("Alarme_Erreur")

func show_correct_alarm() -> void:
	show_green_overlay()
	for alarm in animation_trees:
		var playback = alarm.get("parameters/playback")
		playback.travel("Alarme_Correct")

func do_screen_shake_decay(initial_intensity: float = 1.0, duration: float = 0.5) -> void:
	if not camera:
		return
	var original_pos = camera.position
	var tween = create_tween()
	var steps = 20
	var time_per_step = duration / steps
	for i in steps:
		var progress = float(i) / steps
		var current_intensity = initial_intensity * (1.0 - progress)

		var shake_offset = Vector3(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
		tween.tween_property(camera, "position", original_pos + shake_offset, time_per_step)
	tween.tween_property(camera, "position", original_pos, time_per_step)

func show_red_overlay() -> void:
	var tween = create_tween()
	red_overlay.color.a = 0.7
	tween.tween_property(red_overlay, "color:a", 0, 1)

func show_green_overlay() -> void:
	var tween = create_tween()
	green_overlay.color.a = 0.7
	tween.tween_property(green_overlay, "color:a", 0, 1)
