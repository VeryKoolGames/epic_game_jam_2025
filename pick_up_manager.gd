extends Node

var pickable_item: PickUpItem
var is_carrying_item := false
var carry_offset := Vector3(0, 0, 2)
@export var animation_bras_tree: AnimationTree
@export var arm_transform: Node3D

func _ready() -> void:
	Events.pick_up_item_dropped_in_cauldron.connect(on_item_droped_in_cauldron)

func _is_multiplayer_authority() -> bool:
	return get_parent().is_multiplayer_authority()

@rpc("any_peer", "call_remote", "reliable")
func sync_holding_animation(is_holding: bool):
	if is_holding:
		play_holding_anim()
	else:
		stop_holding_anim()

		
func change_pickable_layer() -> void:
	if pickable_item:
		pickable_item.collision_layer = 1 << 1
	print("Layer mask:", pickable_item.collision_layer)


func set_pickable_to_layer_1_and_2() -> void:
	if pickable_item:
		pickable_item.collision_layer = (1 << 0) | (1 << 1)

@rpc("any_peer", "call_remote", "reliable")
func sync_carrying_state(carrying: bool):
	is_carrying_item = carrying
	owner.is_holding = carrying

func on_item_droped_in_cauldron(_item: ResPickableItem) -> void:
	is_carrying_item = false
	pickable_item = null
	stop_holding_anim()
	sync_holding_animation.rpc(false)
	sync_carrying_state.rpc(false)

func _input(event: InputEvent) -> void:
	if not _is_multiplayer_authority():
		return

	if event.is_action_pressed("pickup") and pickable_item and is_carrying_item:
		SoundManager.play_throw_sounds()
		stop_holding_anim()
		set_pickable_to_layer_1_and_2()
		sync_holding_animation.rpc(false)
		#sync_carrying_state.rpc(false)
		pickable_item.freeze = false
		release_item()
		_apply_force_to_item()

		if _is_multiplayer_authority() and pickable_item:
			pickable_item.update_item_position.rpc(pickable_item.global_transform.origin)

	elif event.is_action_pressed("pickup") and pickable_item and not is_carrying_item:
		print("Picking up item")
		pick_up_item()
		var player_id = get_parent().name.to_int()
		print("I am am ", player_id, "And I just picked up an item")
		pickable_item.player = get_parent()
		pickable_item._set_multiplayer_authority.rpc(player_id)

func release_item()	-> void:
	pickable_item = null
	owner.is_holding = false
	is_carrying_item = false
	stop_holding_anim()
	
func play_holding_anim() -> void:
	animation_bras_tree.set("parameters/conditions/Holding", true)
	animation_bras_tree.set("parameters/conditions/idle", false)

func stop_holding_anim() -> void:
	animation_bras_tree.set("parameters/conditions/Holding", false)
	animation_bras_tree.set("parameters/conditions/idle", true)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup") and not is_carrying_item:
		owner.can_interact = false
		pickable_item = area.get_parent()
		#pickable_item.activate_outline()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup") and not is_carrying_item and pickable_item:
		owner.can_interact = true
		#pickable_item.deactivate_outline()
		pickable_item.freeze = false
		pickable_item = null

func _apply_force_to_item() -> void:
	if pickable_item:
		var force_direction = - (get_parent().global_transform.origin - pickable_item.global_transform.origin).normalized()
		var force_magnitude := 50.0
		pickable_item.apply_central_impulse(force_direction * force_magnitude)

func _process(_delta: float) -> void:
	if pickable_item and is_carrying_item and _is_multiplayer_authority() and not pickable_item.is_reseting:
		var carried_position = arm_transform.to_global(carry_offset)
		pickable_item.global_transform.origin = carried_position
		pickable_item.update_item_position.rpc(carried_position)

func pick_up_item() -> void:
	if not _is_multiplayer_authority():
		return
	change_pickable_layer()
	
	play_holding_anim()
	sync_holding_animation.rpc(true)

	var tween = create_tween()
	tween.tween_callback(Callable(self, "_finish_pickup"))
	var target_pos = arm_transform.to_global(carry_offset)
	var target_rot = arm_transform.global_transform.basis.get_euler()
	tween.tween_property(pickable_item, "global_position", target_pos, 0.1)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(pickable_item, "rotation", target_rot, 0.1)
	tween.set_parallel()

func _finish_pickup():
	if not _is_multiplayer_authority() or not pickable_item:
		return
	pickable_item.freeze = true
	is_carrying_item = true
	owner.is_holding = true

	sync_carrying_state.rpc(true)
