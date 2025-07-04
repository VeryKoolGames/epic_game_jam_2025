extends Activable

@export var mesh: MeshInstance3D
var outline_material: ShaderMaterial
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	outline_material = mesh.material_overlay
	Events.wrong_button_pressed.connect(reset_lever)
	Events.on_challenge_created.connect(_reset_after_challenge_completed)

func _reset_after_challenge_completed(_challenge: Challenge) -> void:
	reset_lever()

func activate() -> void:
	SoundManager.play_lever_sound()
	is_active = true
	animation_player.play("activate_lever")
	activate_lever_rpc.rpc()

@rpc("any_peer")
func activate_lever_rpc() -> void:
	animation_player.play("activate_lever")

@rpc("any_peer")
func reset_lever_rpc() -> void:
	if not is_active:
		return
	animation_player.play("activate_lever")
	is_active = false

func reset_lever() -> void:
	if not is_active:
		return
	animation_player.play_backwards("activate_lever")
	is_active = false
	reset_lever_rpc.rpc()

func activate_outline() -> void:
	if outline_material:
		outline_material.set_shader_parameter("thickness", outline_thickness)

func deactivate_outline() -> void:
	if outline_material:
		outline_material.set_shader_parameter("thickness", 0.0)
