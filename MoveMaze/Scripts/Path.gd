extends KinematicBody2D

var Connections
var Moveable
var Item
var Index

var _target_pos
var grid_obj

func _ready():
	grid_obj = get_parent()
	_target_pos = position
	pass
	
func init(index, connections, moveable, item=null):
	Index = index
	Connections = connections
	Moveable = moveable
	Item = item
	
func _process(delta):
	if _target_pos != position:
		_move_toward_target()
		
func _move_toward_target():

	var vel = (_target_pos - position).normalized() * 200

	if (_target_pos - position).length() > 5:
		move_and_slide(vel)
	else:
		position = _target_pos

func set_target(target, is_instant=false):
	if is_instant:
		position = target
	else:
		_target_pos = target


func collect_item():
	
	var temp_item = Item
	Item = null
	return temp_item
		
