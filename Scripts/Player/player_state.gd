class_name PlayerState extends State

const POINTING = "Pointing"
const CARRYING = "Carrying"
const IDLE = "Idle"
const MOVING = "Moving"

var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
