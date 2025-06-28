extends Node

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

func _on_host_pressed() -> void:
	peer.create_server(64359)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_connected.connect(_sync_world_state)
	_add_player()
	_setup_items()
	$Control.hide()

func _setup_items():
	var items = get_tree().get_nodes_in_group("pickup")
	for item in items:
		item.set_multiplayer_authority(1)
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _sync_world_state(id: int):
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

func _on_join_pressed() -> void:
	peer.create_client("192.168.222.29", 64359)
	multiplayer.multiplayer_peer = peer
	$Control.hide()
