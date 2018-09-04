extends KinematicBody2D

var direction = Vector2()
const NONE = Vector2()
const UP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)

var moving = false

var grid_obj
var speed = 200
var velocity = Vector2()

var t_pos = Vector2()

func _ready():
	grid_obj = get_parent()

func _process(delta):
	
	
	if Input.is_action_just_pressed("ui_up"):
		direction = UP
	elif Input.is_action_just_pressed("ui_down"):
		direction = DOWN
	elif Input.is_action_just_pressed("ui_left"):
		direction = LEFT
	elif Input.is_action_just_pressed("ui_right"):
		direction = RIGHT
	else:
		direction = NONE
	
	if direction != NONE:
		t_pos = grid_obj.get_next_cell_position(position, direction)
		
	
	#position = t_pos
	var vel = (t_pos - position).normalized() * speed
	
	if (t_pos - position).length() > 5:
		move_and_slide(vel)
	else:
		position = t_pos
