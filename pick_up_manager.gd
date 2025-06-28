extends Node

var pickable_item: PickUpItem
var is_carrying_item := false
var carry_offset := Vector3(0, 0, 2)
@export var animation_bras_tree: AnimationTree
@export var arm_transform: Node3D

func _is_multiplayer_authority() -> bool:
	return get_parent().is_multiplayer_authority()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and pickable_item and is_carrying_item:
		stop_holding_anim()
		pickable_item.freeze = false
		owner.is_holding = false
		_apply_force_to_item()
		is_carrying_item = false
		if _is_multiplayer_authority():
			pickable_item.update_item_position.rpc(pickable_item.global_transform.origin)
	elif event.is_action_pressed("pickup") and pickable_item and not is_carrying_item:
		pick_up_item()
		var player_id = get_parent().name.to_int()
		pickable_item._set_multiplayer_authority.rpc(player_id)

func play_holding_anim() -> void:
	animation_bras_tree.set("parameters/conditions/Holding", true)
	animation_bras_tree.set("parameters/conditions/idle", false)

func stop_holding_anim() -> void:
	animation_bras_tree.set("parameters/conditions/Holding", false)
	animation_bras_tree.set("parameters/conditions/idle", true)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup"):
		pickable_item = area.get_parent()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup") and not is_carrying_item:
		pickable_item = null

func _apply_force_to_item() -> void:
	if pickable_item:
		var force_direction = (get_parent().global_transform.origin - pickable_item.global_transform.origin).normalized()
		var force_magnitude := 5.0
		pickable_item.apply_central_impulse(force_direction * force_magnitude)

func _process(_delta: float) -> void:
	if pickable_item and is_carrying_item and _is_multiplayer_authority():
		var target_pos = arm_transform.global_position
		var carried_position = arm_transform.to_global(carry_offset)
		pickable_item.global_transform.origin = carried_position
		pickable_item.update_item_position.rpc(target_pos)

func pick_up_item() -> void:
	play_holding_anim()
	var tween = create_tween()
	tween.tween_callback(Callable(self, "_finish_pickup"))
	var target_pos = arm_transform.to_global(carry_offset)
	var target_rot = arm_transform.global_transform.basis.get_euler()
	tween.tween_property(pickable_item, "global_position", target_pos, 0.3)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(pickable_item, "rotation", target_rot, 0.3)

func _finish_pickup():
	pickable_item.freeze = true
	is_carrying_item = true
	owner.is_holding = true
