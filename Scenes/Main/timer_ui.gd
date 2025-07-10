extends Control

@onready var timer = $Timer
@onready var timer_label = $Label
var is_timer_running := false

func _ready() -> void:
	Events.on_final_challenge_started.connect(_start_timer)
	Events.on_final_challenge_completed.connect(_stop_timer)
	timer.timeout.connect(_on_timer_end)

func _show_ui() -> void:
	scale = Vector2.ZERO
	show()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func _start_timer() -> void:
	_show_ui()
	await get_tree().create_timer(2).timeout
	timer.start()
	is_timer_running = true

func _stop_timer() -> void:
	timer.stop()
	is_timer_running = false
	_hide_ui()

func _hide_ui() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(func(): self.hide())

func _process(_delta: float) -> void:
	if is_timer_running:
		timer_label.text = "%.2f" % timer.time_left

func _on_timer_end() -> void:
	is_timer_running = false
	Events.on_game_lost.emit()
	_hide_ui()
