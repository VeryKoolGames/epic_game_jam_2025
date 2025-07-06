extends Node

@onready var loading_screen = %LoadingScreen as LoadingScreen
@onready var scene_container = %SceneContainer as Control
var first_scene_path = "res://Scenes/start_menu.tscn"
var current_scene: Node

func _ready() -> void:
	loading_screen.play_scene_transition_in()
	Events.on_scene_transition.connect(load_next_scene)

func load_next_scene(path: String) -> void:
	loading_screen.load_scene(path, Enums.TRANSITIONS_TYPES.CIRCLE)

func clear_scene_container() -> void:
	for child in scene_container.get_children():
		child.queue_free()

func on_load_finished(path: String) -> void:
	clear_scene_container()
	var new_scene = load(path).instantiate() as Node
	scene_container.add_child(new_scene)
	current_scene = new_scene
	await get_tree().process_frame
	Events.scene_loaded.emit(current_scene)
	loading_screen.play_scene_transition_in()

func get_current_scene() -> Node:
	return current_scene
