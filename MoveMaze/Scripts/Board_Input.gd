extends Area2D

onready var board_obj = get_parent()

func _ready():
	board_obj.connect("board_ready", self, "setup_collider")
	
func setup_collider():
	var collider = get_child(0)
	
	var extent = board_obj.board_size * board_obj.tile_size
	
	collider.shape.extents = extent / 2
	collider.position = extent / 2
	
	
func _input_event(viewport, event, shape_idx):
	if event.is_pressed():
		var path = board_obj.get_path_from_world(event.position)
		var r = board_obj.route_finder._get_reach(path)
		
	pass