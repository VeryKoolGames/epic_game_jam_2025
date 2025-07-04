class_name ArmStateMachine extends StateMachine

func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		return
	
	if target_state_path == "Pointing" and state.name == "Holding":
		return
	if target_state_path == state.name:
		return
	
	print("Transitioning to state: ", target_state_path)
	print("Current state: ", state.name)
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
