extends Control

@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.new_recipe_generated.connect(on_challenge_created)

func on_challenge_created(_dict: Dictionary) -> void:
	label.text = "Challenge cooking chosen"
