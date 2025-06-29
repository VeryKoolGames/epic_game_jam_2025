extends Node

var current_activable: Activable

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and current_activable:
		current_activable.activate()
		print(owner.name.to_int())
		print(ChallengeManager.can_complete_challenge(owner.name.to_int()))
		if ChallengeManager.can_complete_challenge(owner.name.to_int()):
			Events.try_combination.emit(current_activable.id)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("activable") and owner.can_interact and not area.get_parent().is_active:
		owner.can_interact = false
		current_activable = area.get_parent()
		#current_activable.activate_outline()


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("activable") and not owner.can_interact:
		#current_activable.deactivate_outline()
		current_activable = null
		owner.can_interact = true
