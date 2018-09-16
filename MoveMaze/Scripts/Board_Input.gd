extends Area2D

onready var board_obj = get_parent()

signal board_interaction

func _ready():
	board_obj.connect("board_ready", self, "resize_collider")
	self.connect("board_interaction", board_obj, "board_interaction")
		
func resize_collider():
	var collider = get_child(0)
	
	var extent = board_obj.board_size * board_obj.tile_size
	
	collider.shape.extents = extent / 2
	collider.position = extent / 2
	
	
func _input_event(viewport, event, shape_idx):
	if event.is_pressed():
		emit_signal("board_interaction", event)
	pass