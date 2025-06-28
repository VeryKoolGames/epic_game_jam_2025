extends Node

var can_use_emotes := true
@onready var thumbs_up_anim = $ThumbsUp/AnimationPlayer
@onready var thumbs_down_anim = $ThumbDown/AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("no") and can_use_emotes:
		emote_cooldown()
		SoundManager._play_no_sound()
		play_thumbs_down_emote()
	if event.is_action_pressed("yes") and can_use_emotes:
		emote_cooldown()
		SoundManager._play_yes_sound()
		play_thumbs_up_emote()

func emote_cooldown() -> void:
	can_use_emotes = false
	await get_tree().create_timer(5).timeout
	can_use_emotes = true

func play_thumbs_up_emote() -> void:
	play_anim_rpc.rpc(owner.name.to_int())
	thumbs_up_anim.play("thumbs_up")

@rpc("any_peer")
func play_anim_rpc(sender_id: int) -> void:
	print(multiplayer.get_unique_id())
	print(sender_id)
	if multiplayer.get_unique_id() != sender_id:
		thumbs_up_anim.play("thumbs_up")

func play_thumbs_down_emote() -> void:
	play_down_anim_rpc.rpc(owner.name.to_int())
	thumbs_down_anim.play("thumb_down")

@rpc("any_peer")
func play_down_anim_rpc(sender_id: int) -> void:
	if multiplayer.get_unique_id() != sender_id:
		thumbs_down_anim.play("thumb_down")
