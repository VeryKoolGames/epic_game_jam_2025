extends Control

@export var cauldron_quest_line_scene: PackedScene
@export var unknown_quest_line_scene: PackedScene
@onready var animation_player = $UI_Anim
@onready var box_container = $FeuilleContainer/VBoxContainer
@onready var box_container_done = $FeuilleContainer/Vus
var is_map_open := false
var can_open_map := true

func _ready() -> void:
	Events.on_challenge_created.connect(_generate_challenge_line)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("see_map") and can_open_map:
		_map_open_cooldown()
		_open_or_close_map()

func _map_open_cooldown() -> void:
	can_open_map = false
	await get_tree().create_timer(1).timeout
	can_open_map = true

func _open_or_close_map() -> void:
	if not is_map_open:
		animation_player.play("UI_Open")
	else:
		animation_player.play("UI_Close")
	is_map_open = not is_map_open

func _generate_challenge_line(challenge: Challenge) -> void:
	if challenge is RecipeManager and not ChallengeManager.can_complete_challenge(owner.player_id):
		var line = cauldron_quest_line_scene.instantiate()
		line.set_ingredients_textures(challenge.current_recipe.ingredients)
		box_container.add_child(line)
		box_container.move_child(line, 0)
	else:
		_generate_unknown_line()
	_generate_line_done()

func _generate_line_done() -> void:
	for idx in range(0, box_container.get_children().size()):
		if idx != 0:
			box_container_done.get_child(idx - 1).show()

func _generate_unknown_line() -> void:
	var line = unknown_quest_line_scene.instantiate()
	box_container.add_child(line)
	box_container.move_child(line, 0)
