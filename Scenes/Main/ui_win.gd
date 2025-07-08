extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.on_game_won.connect(_show_ui)

func _show_ui() -> void:
	scale = Vector2.ZERO
	show()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	$TextureButton.grab_focus()

func _on_texture_button_pressed() -> void:
	get_tree().quit()
