extends Node3D

@export var move_item_left := false
var item: PickUpItem
var direction := 1

func _ready() -> void:
	if move_item_left:
		direction *= -1

func _process(delta: float) -> void:
	if item:
		item.global_position.x += (5 * delta) * direction

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup"):
		item = area.get_parent()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent().is_in_group("pickup") and item:
		item = null
