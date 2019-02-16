extends MarginContainer

var gm

func _ready():
	gm = get_parent().get_node('Game_Master')

func _on_LoadSave_pressed():
	gm.setup_from_autosave()
	visible = false

func _on_NewGame_pressed():
	gm.setup_new_game()
	visible = false
