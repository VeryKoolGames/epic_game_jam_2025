extends Node3D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	Events.on_final_challenge_completed.connect(open_doors)

func open_doors() -> void:
	animation_player.play("PorteOpen")
