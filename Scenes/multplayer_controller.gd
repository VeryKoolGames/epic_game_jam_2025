extends Node

var player_id := -1
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var recipe_manager: RecipeManager
@export var challenge_manager: ChallengeManager

func _on_host_pressed() -> void:
	peer.create_server(5000)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_connected.connect(_sync_world_state)
	_add_player()
	_setup_items()
	player_id = 1
	challenge_manager.create_first_challenge()
	ChallengeManager.player_that_generated_quest = 1
	$Control.hide()
	PlayerIds.player_one_id = 1

func _setup_items():
	var items = get_tree().get_nodes_in_group("pickup")
	for item in items:
		item.set_multiplayer_authority(1)
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	call_deferred("_set_player_position", player, id)
	
func _set_player_position(player: Node, id: int):
	print("Setting player position for ID: ", id)
	if id == 1:
		return
		player.global_position.x -= 15
	else:
#		player.global_position.x += 50
#		player.update_position.rpc_id(id, player.global_position)
		PlayerIds.player_two_id = id

func _sync_world_state(id: int):
	print("Syncing world state for player ID: ", id)
	if multiplayer.is_server():
		var items = get_tree().get_nodes_in_group("pickup")
		for item in items:
			item.update_item_position.rpc_id(id, item.global_transform.origin)

		var all_players = [1] + Array(multiplayer.get_peers())
		for player_id in all_players:
			if player_id != id:
				var player = get_node_or_null(str(player_id))
				if player:
					player.update_position.rpc_id(id, player.global_transform.origin)
		recipe_manager.sync_recipes.rpc_id(id, recipe_manager.get_current_recipe())
		challenge_manager.sync_challenges.rpc_id(id)
		sync_player_id.rpc_id(id, id)
		

@rpc("authority", "call_local")
func sync_player_id(id: int) -> void:
	player_id = id
	print("Player ID synced: ", player_id)
		
func _on_join_pressed() -> void:
	peer.create_client("192.168.1.101", 5000)
	multiplayer.multiplayer_peer = peer
	$Control.hide()
