extends Node

var pickable_item: PickUpItem
var is_carrying_item := false
var carry_offset := Vector3(0, 1, -1) # Position relative au joueur

func _is_multiplayer_authority() -> bool:
	return get_parent().is_multiplayer_authority()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and pickable_item and is_carrying_item:
		pickable_item.freeze = false
		_apply_force_to_item()
		is_carrying_item = false
		if _is_multiplayer_authority():
			pickable_item.update_item_position.rpc(pickable_item.global_transform.origin)
	elif event.is_action_pressed("pickup") and pickable_item and not is_carrying_item:
		pickable_item.freeze = true
		is_carrying_item = true
		var player_id = get_parent().name.to_int()
		pickable_item._set_multiplayer_authority.rpc(player_id)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup"):
		pickable_item = area.get_parent()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup"):
		pickable_item = null

func _apply_force_to_item() -> void:
	if pickable_item:
		var force_direction = -(get_parent().global_transform.origin - pickable_item.global_transform.origin).normalized()
		var force_magnitude := 5.0
		pickable_item.apply_central_impulse(force_direction * force_magnitude)

func _process(_delta: float) -> void:
	if pickable_item and is_carrying_item and _is_multiplayer_authority():
		var target_pos = get_parent().global_transform.origin
		pickable_item.global_transform.origin = target_pos
		pickable_item.update_item_position.rpc(target_pos)
