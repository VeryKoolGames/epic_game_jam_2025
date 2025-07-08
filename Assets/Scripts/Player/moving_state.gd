class_name MovingState extends PlayerState
@export var animation_foot_tree: AnimationTree
@export var animation_body_tree: AnimationTree

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

@rpc("any_peer")
func sync_moving_animation_state(is_moving: bool):
	if is_moving:
		animation_foot_tree.set("parameters/conditions/idle", false)
		animation_foot_tree.set("parameters/conditions/moving", true)
		
		animation_body_tree.set("parameters/conditions/Idle", false)
		animation_body_tree.set("parameters/conditions/Moving", true)
	else:
		animation_foot_tree.set("parameters/conditions/idle", true)
		animation_foot_tree.set("parameters/conditions/moving", false)
		
		animation_body_tree.set("parameters/conditions/Idle", true)
		animation_body_tree.set("parameters/conditions/Moving", false)

func enter(previous_state_path: String, data := {}) -> void:
	if owner.is_multiplayer_authority():
		animation_foot_tree.set("parameters/conditions/idle", false)
		animation_foot_tree.set("parameters/conditions/moving", true)
		
		animation_body_tree.set("parameters/conditions/Idle", false)
		animation_body_tree.set("parameters/conditions/Moving", true)
		
		sync_moving_animation_state.rpc(true)
	
func exit() -> void:
	if owner.is_multiplayer_authority():
		animation_foot_tree.set("parameters/conditions/idle", true)
		animation_foot_tree.set("parameters/conditions/moving", false)
		
		animation_body_tree.set("parameters/conditions/Idle", true)
		animation_body_tree.set("parameters/conditions/Moving", false)
		
		sync_moving_animation_state.rpc(false)
