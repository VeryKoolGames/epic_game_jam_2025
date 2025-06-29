extends Node

var player_id := -1
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var recipe_manager: RecipeManager
@export var challenge_manager: ChallengeManager

# Server discovery components
var udp_server: UDPServer
var udp_client: PacketPeerUDP
var discovery_port := 8910
var game_port := 5000
var server_info := {}
var discovery_timer: Timer
var found_servers := []
var is_hosting := false

func _ready():
	discovery_timer = Timer.new()
	discovery_timer.wait_time = 0.5
	discovery_timer.timeout.connect(_handle_discovery)
	add_child(discovery_timer)

func _on_host_pressed() -> void:
	peer.create_server(game_port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_connected.connect(_sync_world_state)
	_add_player()
	player_id = 1
	challenge_manager.create_first_challenge()
	ChallengeManager.player_that_generated_quest = 1
	$StartMenuUI.hide()
	PlayerIds.player_one_id = 1
	
	_start_server_listener()
	is_hosting = true
	print("Server started on port ", game_port)

func _start_server_listener():
	udp_server = UDPServer.new()
	var result = udp_server.listen(discovery_port, "0.0.0.0")
	
	if result != OK:
		print("Failed to start UDP server on port ", discovery_port)
		return
		
	# Prepare server info
	server_info = {
		"name": "Game Server",
		"ip": get_local_ip(),
		"port": game_port,
		"players": 1,
		"max_players": 2
	}
	
	# Start the discovery handler
	discovery_timer.start()
	print("UDP server listening on port ", discovery_port)
	print("Server IP: ", server_info.ip)

func _handle_discovery():
	if is_hosting and udp_server and udp_server.is_listening():
		# Handle incoming discovery requests
		udp_server.poll()
		while udp_server.is_connection_available():
			var client_peer = udp_server.take_connection()
			var packet = client_peer.get_packet()
			
			if packet.size() > 0:
				var message = packet.get_string_from_utf8()
				print("Received discovery message: ", message)
				
				if message == "DISCOVER_SERVERS":
					# Send server info back
					var response = JSON.stringify(server_info)
					client_peer.put_packet(response.to_utf8_buffer())
					print("Sent server info to client")

func _on_join_pressed() -> void:
	$StartMenuUI.hide()
	$LookingUI.show()
	_start_server_discovery()

func _start_server_discovery():
	found_servers.clear()
	print("Starting server discovery...")
	
	# Try multiple approaches to find servers
	_discover_on_localhost()
	_discover_on_network()

func _discover_on_localhost():
	# First try localhost (for testing with multiple instances)
	print("Checking localhost...")
	_try_connect_to_server("127.0.0.1")

func _discover_on_network():
	# Only try network discovery if we haven't found any servers yet
	if found_servers.size() > 0:
		_connect_to_server(found_servers[0])
		return
		
	# Then try network discovery
	udp_client = PacketPeerUDP.new()
	
	# Try connecting to broadcast address
	var result = udp_client.connect_to_host("127.0.0.1", discovery_port)
	if result != OK:
		print("Failed to setup UDP client")
		return
	
	# Send discovery request
	var discovery_message = "DISCOVER_SERVERS"
	udp_client.put_packet(discovery_message.to_utf8_buffer())
	print("Sent discovery request")
	
	# Wait a bit and check for responses
	await get_tree().create_timer(1.0).timeout
	_check_discovery_responses()

func _try_connect_to_server(ip: String):
	# Create a temporary UDP client to test if server is there
	var test_client = PacketPeerUDP.new()
	var result = test_client.connect_to_host(ip, discovery_port)
	
	if result == OK:
		# Send discovery request
		test_client.put_packet("DISCOVER_SERVERS".to_utf8_buffer())
		
		# Wait a moment for response
		await get_tree().create_timer(0.5).timeout
		
		# Check for response
		if test_client.get_available_packet_count() > 0:
			var packet = test_client.get_packet()
			var response = packet.get_string_from_utf8()
			
			var json = JSON.new()
			var parse_result = json.parse(response)
			
			if parse_result == OK:
				var server_data = json.data
				if server_data.has("ip") and server_data.has("port"):
					print("Found server via direct check: ", server_data)
					found_servers.append(server_data)  # Add to found servers instead of connecting immediately
					test_client.close()
					return
	
	test_client.close()
	print("No server found on ", ip)

func _check_discovery_responses():
	var response_found = false
	
	if udp_client and udp_client.get_available_packet_count() > 0:
		while udp_client.get_available_packet_count() > 0:
			var packet = udp_client.get_packet()
			var response = packet.get_string_from_utf8()
			
			var json = JSON.new()
			var parse_result = json.parse(response)
			
			if parse_result == OK:
				var server_data = json.data
				if server_data.has("ip") and server_data.has("port"):
					found_servers.append(server_data)
					print("Found server via broadcast: ", server_data)
					response_found = true
	
	if response_found and found_servers.size() > 0:
		_connect_to_server(found_servers[0])
	else:
		print("No servers found via discovery!")
		$StartMenuUI.show()
		$LookingUI.hide()
	
	# Cleanup
	if udp_client:
		udp_client.close()

func _connect_to_server(server_data):
	$LookingUI.hide()
	print("Connecting to server at ", server_data.ip, ":", server_data.port)
	
	# Reset multiplayer peer if already active
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	# Create new peer
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(server_data.ip, int(server_data.port))
	
	if result != OK:
		print("Failed to create client: ", result)
		$StartMenuUI.show()
		$LookingUI.hide()
		return
		
	multiplayer.multiplayer_peer = peer
	
	# Connect signals only if not already connected
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connected_to_server():
	print("Successfully connected to server!")

func _on_connection_failed():
	print("Failed to connect to server!")
	$StartMenuUI.show()
	$LookingUI.hide()

func get_local_ip() -> String:
	var ip_list = IP.get_local_addresses()
	for ip in ip_list:
		if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return "127.0.0.1"  # fallback

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
		sync_player_id.rpc_id(id, id)

@rpc("authority", "call_local")
func sync_player_id(id: int) -> void:
	player_id = id

# Clean up when the node is removed
func _exit_tree():
	if discovery_timer:
		discovery_timer.stop()
	if udp_server:
		udp_server.stop()
	if udp_client:
		udp_client.close()

# Debug function - you can call this to test UDP
func _test_udp():
	print("Testing UDP setup...")
	print("Local IP: ", get_local_ip())
	print("Available addresses: ", IP.get_local_addresses())
