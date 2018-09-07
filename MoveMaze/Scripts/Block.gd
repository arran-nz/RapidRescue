extends KinematicBody2D


var moving = false

var grid_obj
var speed = 200

var _target_pos

func _ready():
	grid_obj = get_parent()
	_target_pos = position

func _process(delta):
	_input_check()
	
	if _target_pos == position: 
		pass
	
	var vel = (_target_pos - position).normalized() * 200

	if (_target_pos - position).length() > 5:
		move_and_slide(vel)
	else:
		position = _target_pos

func _input_check():
	
	if Input.is_action_just_pressed("ui_up"):
		var direction = grid_obj.DIRECTION['N']
		_target_pos = grid_obj.get_next_cell_position(position, direction)
		
	elif Input.is_action_just_pressed("ui_down"):
		var direction = grid_obj.DIRECTION['S']
		_target_pos = grid_obj.get_next_cell_position(position, direction)
		
	elif Input.is_action_just_pressed("ui_left"):
		var direction = grid_obj.DIRECTION['W']
		_target_pos = grid_obj.get_next_cell_position(position, direction)
		
	elif Input.is_action_just_pressed("ui_right"):
		var direction = grid_obj.DIRECTION['E']
		_target_pos = grid_obj.get_next_cell_position(position, direction)
