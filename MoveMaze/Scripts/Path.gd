extends Node2D

var Connections
var Moveable
var Item

var _target_pos
var grid_obj

func _ready():
	grid_obj = get_parent()
	pass
	
func setup(connections, moveable, item=null):
	Connections = connections
	Moveable = moveable
	Item = item
	
func slide(direction, speed):
	_target_pos = grid_obj.get_next_cell_position(position, direction)
	var vel = (_target_pos - position).normalized() * speed

	if (_target_pos - position).length() > 5:
		move_and_slide(vel)
	else:
		position = _target_pos
	pass

func collect_item():
	
	var temp_item = Item
	Item = null
	return temp_item
		
