extends Node
class_name ChallengeManager

static var challenge_counter := 0
@export var challenge_total: int = 5
@export var challenges: Array[Challenge]
static var current_challenge: Challenge
static var player_that_generated_quest: int = 1
static var type: String
@onready var alarm_manager = $AlarmManager

static func is_challenge_button() -> bool:
	return type == "button"

static func is_challenge_recipe() -> bool:
	return type == "recipe"	

@rpc("any_peer")
func _share_challenge_rpc() -> void:
	Events.on_challenge_created.emit(current_challenge)

@rpc("any_peer")
func _share_challenge_creator(player_id: int) -> void:
	player_that_generated_quest = player_id

@rpc("authority", "call_local")
func sync_challenges() -> void:
	_share_challenge_rpc()

@rpc("any_peer")
func _share_challenge_counter(counter: int) -> void:
	challenge_counter = counter

@rpc("any_peer")
func on_fail() -> void:
	alarm_manager.show_wrong_alarm()

@rpc("any_peer")
func on_success() -> void:
	alarm_manager.show_correct_alarm()

@rpc("any_peer")
func _share_new_challenge(_type: String) -> void:
	type = _type

func _share_challenge() -> void:
	Events.on_challenge_created.emit(current_challenge)

func _ready() -> void:
	for child in get_children():
		if child is Challenge:
			challenges.append(child)
#	Events.on_challenge_completed.connect(create_challenge)
	
func create_challenge() -> void:
	challenge_counter += 1
	if challenge_counter >= challenge_total:
		create_challenge()
		return
	current_challenge = challenges[randi_range(0, challenges.size() - 1)].create_challenge()
	player_that_generated_quest = MultiplayerManager.player_id
	_share_challenge_creator.rpc(MultiplayerManager.player_id)
	_share_challenge_rpc.rpc()
	_share_challenge_counter.rpc(challenge_counter)
	_share_challenge()
	if current_challenge is ButtonManager:
		type = "button"
	elif current_challenge is RecipeManager:
		type = "recipe"
	_share_new_challenge.rpc(type)

func create_last_challenge() -> void:
	pass

func create_first_challenge() -> void:
	current_challenge = challenges[0].create_challenge()
	_share_challenge_creator.rpc(MultiplayerManager.player_id)
	_share_challenge()
	_share_challenge_rpc.rpc()
	type = "recipe"
	_share_new_challenge.rpc(type)

static func can_complete_challenge(player_id: int) -> bool:
	return player_id != player_that_generated_quest

func on_fail_challenge():
	on_fail.rpc()
	alarm_manager.show_wrong_alarm()

func on_success_challenge():
	on_success.rpc()
	alarm_manager.show_correct_alarm()
