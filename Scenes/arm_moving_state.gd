class_name ArmMovingState extends ArmState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

@rpc("any_peer")
func sync_moving_animation_state(is_moving: bool):
	if is_moving:
		animation_tree.travel("Bras_Moving")
	else:
		animation_tree.travel("Bras_Idle")

func enter(previous_state_path: String, data := {}) -> void:
	if owner.is_multiplayer_authority():
		animation_tree.travel("Bras_Moving")
		sync_moving_animation_state.rpc(true)

func exit() -> void:
	if owner.is_multiplayer_authority():
		animation_tree.travel("Bras_Idle")
		
		sync_moving_animation_state.rpc(false)
