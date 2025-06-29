extends Node

signal new_recipe_generated(recipe: Dictionary)
signal new_buttons_challenge_generated(combinaison: Array)
signal pick_up_item_dropped_in_cauldron(item: ResPickableItem)
signal on_challenge_created(challenge: Challenge)
signal on_challenge_completed
signal wrong_button_pressed
signal try_combination(id: int, player_id: int)
