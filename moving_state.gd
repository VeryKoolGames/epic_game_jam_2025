class_name MovingState extends PlayerState

@export var animation_foot_tree: AnimationTree
@export var animation_body_tree: AnimationTree

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	animation_foot_tree.set("parameters/conditions/idle", false)
	animation_foot_tree.set("parameters/conditions/moving", true)
	
	animation_body_tree.set("parameters/conditions/Idle", false)
	animation_body_tree.set("parameters/conditions/Moving", true)

func exit() -> void:
	animation_foot_tree.set("parameters/conditions/idle", true)
	animation_foot_tree.set("parameters/conditions/moving", false)
	
	animation_body_tree.set("parameters/conditions/Idle", true)
	animation_body_tree.set("parameters/conditions/Moving", false)
