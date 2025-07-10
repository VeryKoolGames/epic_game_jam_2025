extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.on_game_won.connect(_show_ui)

func _show_ui() -> void:
	Events.on_scene_shown_circle_transition.emit(self)

func _on_texture_button_pressed() -> void:
	print("Click detected")
	get_tree().quit()
