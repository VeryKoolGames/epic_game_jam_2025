class_name ArmReadingState extends ArmState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

@rpc("any_peer")
func sync_moving_animation_state(is_moving: bool):
	if is_moving:
		animation_tree.travel("Bras_Reading")
	else:
		animation_tree.travel("Bras_Idle")

func enter(previous_state_path: String, data := {}) -> void:
	animation_tree.travel("Bras_Reading")
	sync_moving_animation_state.rpc(true)

func exit() -> void:
	animation_tree.travel("Bras_Idle")
	
	sync_moving_animation_state.rpc(false)
