class_name ArmState extends State

const POINTING = "Pointing"
const HOLDING = "Holding"
const IDLE = "Idle"
const MOVING = "Moving"

var animation_tree: AnimationNodeStateMachinePlayback
var state_machine: StateMachine

func _ready() -> void:
	await owner.ready
	animation_tree = owner["parameters/playback"]
	state_machine = get_parent() as StateMachine
