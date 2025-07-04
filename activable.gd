extends Node3D
class_name Activable

var is_active := false
@export var id: int
@export var outline_thickness: float

func activate() -> void:
	pass

func activate_outline() -> void:
	pass
	
func deactivate_outline() -> void:
	pass
