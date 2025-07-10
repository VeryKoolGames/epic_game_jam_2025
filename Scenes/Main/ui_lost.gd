extends Control


func _ready() -> void:
	Events.on_game_lost.connect(_show_ui)

func _show_ui() -> void:
	Events.on_scene_shown_circle_transition.emit(self)
	$TextureButton.grab_focus()

func _on_texture_button_pressed() -> void:
	get_tree().quit()
