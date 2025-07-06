extends Node

var current_activable: Activable

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and current_activable and ChallengeManager.is_challenge_button():
		current_activable.activate()
		SoundManager.play_button_sound()
		if ChallengeManager.can_complete_challenge(MultiplayerManager.player_id):
			Events.try_combination.emit(current_activable.id, MultiplayerManager.player_id)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("activable") and not area.get_parent().is_active and ChallengeManager.is_challenge_button():
		owner.can_interact = false
		current_activable = area.get_parent()
		current_activable.activate_outline()


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("activable") and current_activable and ChallengeManager.is_challenge_button():
		current_activable.deactivate_outline()
		current_activable = null
		owner.can_interact = true
