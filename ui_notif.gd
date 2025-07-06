extends Control


func _ready() -> void:
	Events.on_challenge_created.connect(activate_ui)
	Events.on_map_opened.connect(deactivate_ui)


func activate_ui(_challenge: Challenge) -> void:
	self.show()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func deactivate_ui() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(func(): self.hide())
