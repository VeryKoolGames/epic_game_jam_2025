extends Control
class_name LoadingScreen

@onready var progress_ui = %Progress
@onready var progress_bar = %ProgressBar
@onready var circle_transition_rect = %CircleTransitionRect
var circle_transition_shader: ShaderMaterial
var path: String
var progress_value := 0.0

func _ready() -> void:
	circle_transition_shader = circle_transition_rect.material as ShaderMaterial

func load_scene(path_to_load: String, transition_type: Enums.TRANSITIONS_TYPES):
	show()
	if transition_type == Enums.TRANSITIONS_TYPES.CIRCLE:
		play_scene_transition(path_to_load)

func play_scene_transition(path_to_load: String) -> void:
	var tween = create_tween()
	tween.tween_property(circle_transition_rect, "material:shader_parameter/circle_size", 0, 1.0)
	tween.tween_callback(start_loading_scene.bind(path_to_load))

func play_scene_transition_out_and_in(scene_to_show: Node) -> void:
	show()
	var tween_out = create_tween()
	tween_out.tween_property(circle_transition_rect, "material:shader_parameter/circle_size", 0.0, 1.0)
	tween_out.tween_callback(func(): scene_to_show.show())
	await tween_out.finished
	var tween_in = create_tween()
	tween_in.tween_property(circle_transition_rect, "material:shader_parameter/circle_size", 1.0, 1.0)
	tween_in.tween_callback(func(): self.hide())

func start_loading_scene(path_to_load: String) -> void:
	progress_ui.show()
	path = path_to_load
	ResourceLoader.load_threaded_request(path)

func _process(delta: float):
	if not path:
		return

	var progress = []
	var status = ResourceLoader.load_threaded_get_status(path, progress)

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		progress_value = progress[0] * 100
		progress_bar.value = move_toward(progress_bar.value, progress_value, delta * 20)

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		progress_bar.value = move_toward(progress_bar.value, 100.0, delta * 150)

		if progress_bar.value >= 99.99:
			progress_bar.value = 100
			progress_ui.hide()
			owner.on_load_finished(path)
			path = ""

func play_scene_transition_in() -> void:
	var tween = create_tween()
	tween.tween_property(circle_transition_rect, "material:shader_parameter/circle_size", 1.0, 1.0)
	tween.tween_callback(reset_values)

func reset_values() -> void:
	progress_bar.value = 0
	circle_transition_shader.set_shader_parameter("circle_size", 1.0)
	hide()
