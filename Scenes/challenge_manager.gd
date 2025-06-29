extends Node
class_name ChallengeManager

static var challenge_counter := 0
@export var challenge_total: int = 5
@export var challenges: Array[Challenge]
var current_challenge: Challenge
static var player_that_generated_quest: int = 1

@rpc("any_peer")
func _share_challenge_rpc() -> void:
	Events.on_challenge_created.emit(current_challenge)

@rpc("any_peer")
func _share_challenge_creator(player_id: int) -> void:
	player_that_generated_quest = player_id

@rpc("authority", "call_local")
func sync_challenges() -> void:
	_share_challenge_rpc()

func _share_challenge() -> void:
	Events.on_challenge_created.emit(current_challenge)

func _ready() -> void:
	for child in get_children():
		if child is Challenge:
			challenges.append(child)
	Events.on_challenge_completed.connect(create_challenge)
	
func create_challenge() -> void:
	challenge_counter += 1
	if challenge_counter >= challenge_total:
		print("Game finish")
	current_challenge = challenges[randi_range(0, challenges.size() - 1)].create_challenge()
	player_that_generated_quest = owner.player_id
	print("Challenge created by player ID: ", player_that_generated_quest)
	_share_challenge_creator.rpc(owner.player_id)
	_share_challenge_rpc.rpc()
	_share_challenge()

func create_first_challenge() -> void:
	current_challenge = challenges[randi_range(0, challenges.size() - 1)].create_challenge()
	print("First challenge created by player ID: ", owner.player_id)
	_share_challenge_creator.rpc(owner.player_id)
	_share_challenge()
	_share_challenge_rpc.rpc()

static func can_complete_challenge(player_id: int):
	return player_id != player_that_generated_quest
