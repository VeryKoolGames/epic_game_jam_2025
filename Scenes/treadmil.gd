extends Node3D

var item: PickUpItem

func _process(delta: float) -> void:
	if item:
		item.global_position.x += 5 * delta

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup"):
		item = area.get_parent()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup") and item:
		item = null
