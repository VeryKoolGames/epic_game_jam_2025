extends Activable

@export var mesh: MeshInstance3D
@export var outline_material: ShaderMaterial
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	outline_material = mesh.material_overlay as ShaderMaterial
	Events.wrong_button_pressed.connect(on_wrong_button_pressed)

func activate_outline() -> void:
	if outline_material:
		outline_material.set_shader_parameter("thickness", outline_thickness)

func deactivate_outline() -> void:
	if outline_material:
		outline_material.set_shader_parameter("thickness", 0.0)

func activate() -> void:
	SoundManager.play_button_sound()
	is_active = true
	animation_player.play("push_button")
	activate_button_rpc.rpc()

func on_wrong_button_pressed() -> void:	
	if not is_active:
		return
	animation_player.play_backwards("push_button")
	deactivate_outline()
	wrong_button_rpc.rpc()
	is_active = false

@rpc("any_peer")
func wrong_button_rpc() -> void:
	animation_player.play_backwards("push_button")	

@rpc("any_peer")
func activate_button_rpc() -> void:
	animation_player.play("push_button")
