extends Activable

@export var mesh: MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func activate() -> void:
	SoundManager.play_lever_sound()
	is_active = true
	animation_player.play("activate_lever")
	activate_lever_rpc.rpc()

@rpc("any_peer")
func activate_lever_rpc() -> void:
	animation_player.play("activate_lever")
