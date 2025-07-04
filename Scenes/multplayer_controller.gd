extends Node

var player_id := -1
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var recipe_manager: RecipeManager
@export var challenge_manager: ChallengeManager
@export var IpUI: Control
@export var IpLineEdit: LineEdit

func _on_host_pressed() -> void:
	var result = peer.create_server(5000)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_connected.connect(_hide_ip)
	multiplayer.peer_connected.connect(_sync_world_state)
	_add_player()
	_setup_items()
	player_id = 1
	challenge_manager.create_first_challenge()
	ChallengeManager.player_that_generated_quest = 1
	$StartMenuUI.hide()
	PlayerIds.player_one_id = 1

	var server_ip = get_local_ip()
	print("Server started on IP: ", server_ip)

	_show_server_ip(server_ip)

func _hide_ip(id: int) -> void:
	$ServerUI.hide()

func _show_server_ip(ip: String):
	$ServerUI.show()
	$ServerUI/Label.text = "Server IP: " + ip

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
		# Keep valid private network IPs
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
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	call_deferred("_set_player_position", player, id)

func _set_player_position(player: Node, id: int):
	if id == 1:
		return
		player.global_position.x -= 15
	else:
		PlayerIds.player_two_id = id
		_set_players_ids.rpc(PlayerIds.player_two_id)

@rpc("any_peer")
func _set_players_ids(player_two_id: int) -> void:
	PlayerIds.player_one_id = 1
	PlayerIds.player_two_id = player_two_id

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
		recipe_manager.sync_recipes.rpc_id(id, recipe_manager.get_current_recipe())
		challenge_manager.sync_challenges.rpc_id(id)
		challenge_manager._share_new_challenge.rpc_id(id, challenge_manager.type)
		sync_player_id.rpc_id(id, id)

@rpc("authority", "call_local")
func sync_player_id(id: int) -> void:
	player_id = id

func _on_join_pressed() -> void:
	_show_ip_input()

func _show_ip_input():
	IpUI.show()

func _on_cancel_connection(dialog: AcceptDialog):
	dialog.queue_free()
	$StartMenuUI.show()

func _connect_to_server(server_ip: String):
	var result = peer.create_client(server_ip, 5000)
	print("Connection result", result)
	if result != OK:
		print("Failed to create client: ", result)
		return
	multiplayer.multiplayer_peer = peer
	$StartMenuUI.hide()

func _on_connection_failed():
	print("Failed to connect to server!")
	_show_connection_error("Connection failed")

func _show_connection_error(message: String):
	print("Connection error: ", message)

func _on_ip_button_pressed() -> void:
	var ip = IpLineEdit.text.strip_edges()
	if ip != "":
		IpUI.hide()
		_connect_to_server(ip)
	else:
		print("Please enter an IP address")
