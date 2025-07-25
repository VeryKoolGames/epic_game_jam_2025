extends Node

@warning_ignore_start("unused_signal")
signal new_buttons_challenge_generated(combinaison: Array)
signal pick_up_item_dropped_in_cauldron(item: ResPickableItem)
signal on_challenge_created(challenge: Challenge)
signal on_map_opened
signal on_map_closed
signal wrong_button_pressed
signal try_combination(id: int, player_id: int)

signal on_final_challenge_completed
signal on_final_challenge_started
signal on_exit_reached
signal on_game_lost
signal on_game_won
signal on_scene_shown_circle_transition(scene_to_show: Node)

# MULTIPLAYER CONNECTION MANAGEMENT
signal on_host_connected
signal on_client_connected

# SCENE MANAGMENT
signal scene_loaded(scene: Node)
signal on_scene_transition(path: String)
