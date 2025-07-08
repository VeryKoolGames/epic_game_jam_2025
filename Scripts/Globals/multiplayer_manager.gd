extends Node

var player_id := -1
var peer = ENetMultiplayerPeer.new()
var player_scene: PackedScene
var recipe_manager: RecipeManager
var challenge_manager: ChallengeManager

var main_game_scene_path = "res://Scenes/Main/main.tscn"
var player_one_path = "res://Scenes/Player/PlayerOne.tscn"
var player_two_path = "res://Scenes/Player/PlayerTwo.tscn"
var current_scene: Node
var server_ip: String

signal connection_established
signal connection_failed

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game():
	var result = peer.create_server(5000)
	if result != OK:
		print("Failed to create server: ", result)
		connection_failed.emit()
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_connected.connect(_sync_world_state)
	
	player_id = 1
	
	server_ip = get_local_ip()
	
	Events.scene_loaded.connect(_setup_host_game)

func _setup_host_game(main_scene: Node):
	current_scene = main_scene
	recipe_manager = current_scene.get_node("ChallengeManager/RecipeManager")
	challenge_manager = current_scene.get_node("ChallengeManager")
	player_scene = load(player_one_path)
	
	_add_player()
	_setup_items()
	challenge_manager.create_first_challenge()
	ChallengeManager.player_that_generated_quest = 1
	
	connection_established.emit()
	Events.scene_loaded.disconnect(_setup_host_game)
	Events.on_host_connected.emit(server_ip)

func join_game(server_ip: String):
	var result = peer.create_client(server_ip, 5000)
	if result != OK:
		connection_failed.emit()
		return
	Events.scene_loaded.connect(_connect_client)

func _connect_client(main_scene: Node) -> void:
	current_scene = main_scene
	# HERE THE CONECTED METHODS ARE TRIGGERED
	multiplayer.multiplayer_peer = peer
	Events.scene_loaded.disconnect(_connect_client)

func _on_connected_to_server():
	connection_established.emit()

func _on_connection_failed():
	print("Failed to connect to server!")
	connection_failed.emit()

func _on_server_disconnected():
	print("Server disconnected!")
	get_tree().change_scene_to_file("res://Scenes/Main/main.tscn")

func get_local_ip() -> String:
	var ip_list = IP.get_local_addresses()
	print("All available IPs: ", ip_list)

	var filtered_ips = []
	for ip in ip_list:
		if ip.begins_with("172.17.") or ip.begins_with("172.18.") or ip.begins_with("172.19.") or ip.begins_with("172.20."):
			print("Skipping Docker IP: ", ip)
			continue
		if ip.begins_with("127.") or ip == "::1":
			print("Skipping loopback IP: ", ip)
			continue
		if ip.begins_with("169.254."):
			print("Skipping link-local IP: ", ip)
			continue
		if ip.begins_with("192.168.") or ip.begins_with("10.") or (ip.begins_with("172.") and not ip.begins_with("172.17")):
			filtered_ips.append(ip)

	print("Filtered IPs: ", filtered_ips)

	for ip in filtered_ips:
		if ip.begins_with("192.168."):
			print("Selected IP: ", ip)
			return ip

	for ip in filtered_ips:
		if ip.begins_with("10."):
			print("Selected IP: ", ip)
			return ip

	for ip in filtered_ips:
		if ip.begins_with("172.") and not ip.begins_with("172.17"):
			print("Selected IP: ", ip)
			return ip

	print("No suitable IP found, using fallback")
	return "127.0.0.1"

func _setup_items():
	var items = get_tree().get_nodes_in_group("pickup")
	for item in items:
		item.set_multiplayer_authority(1)

func _add_player(id = 1):
	player_id = id
	var player
	if id == 1:
		player = player_scene.instantiate()
	else:
		player = load(player_two_path).instantiate()
	player.name = str(id)
	get_tree().current_scene.call_deferred("add_child", player)

func _sync_world_state(id: int):
	if multiplayer.is_server():
		var items = get_tree().get_nodes_in_group("pickup")
		for item in items:
			item.update_item_position.rpc_id(id, item.global_transform.origin)
		var all_players = [1] + Array(multiplayer.get_peers())
		for player_id in all_players:
			if player_id != id:
				var player = current_scene.get_node_or_null(str(player_id))
				if player:
					player.update_position.rpc_id(id, player.global_transform.origin)
		recipe_manager.sync_recipes.rpc_id(id, recipe_manager.get_current_recipe())
		challenge_manager.sync_challenges.rpc_id(id)
		challenge_manager._share_new_challenge.rpc_id(id, challenge_manager.type)
		sync_player_id.rpc_id(id, id)
		Events.on_client_connected.emit()

@rpc("authority", "call_local")
func sync_player_id(id: int) -> void:
	player_id = id
