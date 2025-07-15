extends Control

@export var IpUI: Control
@export var IpLineEdit: LineEdit
@export var wrong_ip_label: Label

var main_scene_path: String = "res://Scenes/Main/main.tscn"

func _on_host_pressed() -> void:
	MultiplayerManager.host_game()
	Events.on_scene_transition.emit(main_scene_path)

func _on_join_pressed() -> void:
	_show_ip_input()

func _show_ip_input():
	IpUI.show()

func _on_cancel_connection():
	IpUI.hide()

func _on_connect_button_pressed() -> void:
	var ip = IpLineEdit.text.strip_edges()
	if ip != "":
		if MultiplayerManager.join_game(ip):
			IpUI.hide()
			Events.on_scene_transition.emit(main_scene_path)
		else:
			IpLineEdit.text = ""
			_show_wrong_ip_label()
	else:
		print("Please enter an IP address")

func _show_wrong_ip_label() -> void:
	wrong_ip_label.scale = Vector2.ZERO
	wrong_ip_label.show()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(wrong_ip_label, "scale", Vector2(1.4, 1.4), 0.1)
	tween.tween_property(wrong_ip_label, "scale", Vector2(1.0, 1.0), 0.1)
