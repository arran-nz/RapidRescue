extends Node2D

var current_path = null
onready var grid_obj = get_parent()

func _ready():
	grid_obj.connect("signal_hand", self, "setup_hand")
	pass

func setup_hand(injectors, path):
	current_path = path
	
	for inj in injectors:
		inj.connect("click_action", self, "place_path")

func hold_path(path):
	if(current_path == null):
		current_path = path
	else:
		print("ERROR: CAN ONLY HOLD ONE PATH")

func place_path(board_index, direction):
	grid_obj.inject_path(board_index, direction, current_path)
	
	print("place!")
	pass


func rotate_hand():
	
	pass