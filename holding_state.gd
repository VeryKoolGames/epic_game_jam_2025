class_name HoldingState extends PlayerState

@export var animation_bras_tree: AnimationTree
var pickable_item: PickUpItem
var carry_offset := Vector3(0, 1, -1)

func handle_input(_event: InputEvent) -> void:
	pass
	#if _event.is_action_pressed("pickup"):
		#finished.emit("Idle")

func update(_delta: float) -> void:
	if owner.is_multiplayer_authority() and pickable_item:
		var target_pos = owner.global_transform.origin
		pickable_item.global_transform.origin = target_pos
		pickable_item.update_item_position.rpc(target_pos)
		print(target_pos)

func physics_update(_delta: float) -> void:
	pass

func enter(previous_state_path: String, data := {}) -> void:
	pickable_item = data.get("pickable_item")
	change_pickable_layer()
	var player_id = owner.name.to_int()
	pickable_item._set_multiplayer_authority.rpc(player_id)
	animation_bras_tree.set("parameters/conditions/Holding", true)
	animation_bras_tree.set("parameters/conditions/idle", false)

func change_pickable_layer() -> void:	
	if pickable_item:
		pickable_item.physics_layer = 1 << 1
	print("Layer mask:", pickable_item.physics_layer)
		

func set_pickable_to_layer_1_and_2() -> void:
	if pickable_item:
		pickable_item.physics_layer = (1 << 0) | (1 << 1)

func exit() -> void:
	print("exiting")
	animation_bras_tree.set("parameters/conditions/idle", true)
	animation_bras_tree.set("parameters/conditions/Holding", false)
	set_pickable_to_layer_1_and_2()
	_apply_force_to_item()
	if owner.is_multiplayer_authority():
		pickable_item.update_item_position.rpc(pickable_item.global_transform.origin)

func _apply_force_to_item() -> void:
	var force_direction = -(owner.global_transform.origin - pickable_item.global_transform.origin).normalized()
	var force_magnitude := 5.0
	pickable_item.apply_central_impulse(force_direction * force_magnitude)
