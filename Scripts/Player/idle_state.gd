class_name IdleState extends PlayerState

@export var animation_arm_tree: AnimationTree

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_previous_state_path: String, _data := {}) -> void:
	pass

func exit() -> void:
	pass
