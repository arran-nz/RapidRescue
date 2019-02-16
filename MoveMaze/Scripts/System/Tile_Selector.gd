extends Node

const PD = preload('res://Scripts/Board/Definitions.gd').PathData
const DIRECTION = PD.DIRECTION

var current_index = Vector2(0,0)
var board
var active setget _set_active

var _input_listening

onready var spatial_indicator = $Indicator

func _ready():
	self.active = false

func setup(board, start_active):
	self.board = board
	self.active = start_active
	
func _set_active(value):
	if value:
		if !_input_listening: _sub_inputs()
	else:
		if _input_listening: _unsub_inputs()
	
	spatial_indicator.visible = value
	set_process(value)
	active = value

func _sub_inputs():
	_input_listening = true
	InputManager.subscribe('select', self, 'select_path_from_index')
	InputManager.subscribe('up', self, 'move_up')
	InputManager.subscribe('down', self, 'move_down')
	InputManager.subscribe('left', self, 'move_left')
	InputManager.subscribe('right', self, 'move_right')
	
func _unsub_inputs():
	_input_listening = false
	InputManager.unsubscribe('select', self, 'select_path_from_index')
	InputManager.unsubscribe('up', self, 'move_up')
	InputManager.unsubscribe('down', self, 'move_down')
	InputManager.unsubscribe('left', self, 'move_left')
	InputManager.unsubscribe('right', self, 'move_right')

func select_path_from_index():
	board.get_path(current_index).press_path()

func move_up():
	move_current_index(DIRECTION['N'])
	
func move_down():
	move_current_index(DIRECTION['S'])
	
func move_left():
	move_current_index(DIRECTION['W'])
	
func move_right():
	move_current_index(DIRECTION['E'])

func _process(delta):
	if board:
		var target_pos =  board.map_to_world(current_index.x, 0, current_index.y)
		spatial_indicator.translation = target_pos

func move_current_index(dir):
	var new_pos = current_index + dir
	if board.index_in_board(new_pos):
		# Move to next index
		current_index = new_pos
	else:
		# Wrap around the board
		current_index = new_pos - (dir * board.board_size)
