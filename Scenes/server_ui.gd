extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.on_host_connected.connect(on_host_connected)
	Events.on_client_connected.connect(on_client_connected)

func on_host_connected(ip: String) -> void:
	show()
	$Label.text = "IP: " + ip

func on_client_connected() -> void:
	print("received client event")
	hide()
