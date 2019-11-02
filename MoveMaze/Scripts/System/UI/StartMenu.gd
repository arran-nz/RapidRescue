extends MarginContainer

onready var gm  = get_parent().get_node('Game_Master')
onready var player_count = get_node('Center/VBoxContainer/Players/SpinBox')

func _on_new_pressed():
	var game_config = {
		"players": int(player_count.value),
		"amount_to_rescue": int(5),
	}
	gm.setup_new_game(game_config)
	visible = false


func _on_load_pressed():
	gm.setup_from_autosave()
	visible = false
