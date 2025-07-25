class_name ArmHoldingState extends ArmState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

@rpc("any_peer")
func sync_moving_animation_state(is_moving: bool):
	if is_moving:
		animation_tree.travel("Bras_Holding")
	else:
		animation_tree.travel("Bras_Idle")

func enter(_previous_state_path: String, _data := {}) -> void:
	animation_tree.travel("Bras_Holding")
	sync_moving_animation_state.rpc(true)

func exit() -> void:
	animation_tree.travel("Bras_Idle")
	
	sync_moving_animation_state.rpc(false)
