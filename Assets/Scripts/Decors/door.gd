extends Node3D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	Events.on_final_challenge_completed.connect(open_doors)

func open_doors() -> void:
	animation_player.play("PorteOpen")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Events.on_exit_reached.emit()
		if is_multiplayer_authority():
			on_exit_reached_rpc.rpc()

@rpc("any_peer", "call_remote")
func on_exit_reached_rpc() -> void:
	Events.on_exit_reached.emit()
