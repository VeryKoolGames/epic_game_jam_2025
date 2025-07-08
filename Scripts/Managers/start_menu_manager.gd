extends Control

@export var IpUI: Control
@export var IpLineEdit: LineEdit

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
		IpUI.hide()
		MultiplayerManager.join_game(ip)
		Events.on_scene_transition.emit(main_scene_path)
	else:
		print("Please enter an IP address")
