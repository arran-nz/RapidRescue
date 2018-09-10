extends Node2D

var current_path = null
onready var grid_obj = get_parent()

func _ready():
	grid_obj.connect("injectors_ready", self, "setup_injectors")
	pass

func setup_injectors(injectors):
	for inj in injectors:
		inj.connect("click_action", self, "handle_injector")

func hold_path(path):
	if(current_path == null):
		current_path = path
	else:
		print("ERROR: CAN ONLY HOLD ONE PATH")

func handle_injector(injector):
	grid_obj.inject_path(injector.index, injector.inj_direction, current_path)
	
	print("place!")
	pass


func rotate_hand():
	
	pass