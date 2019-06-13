extends Node

const PD = preload('res://Scripts/Board/Definitions.gd').PathData
const DIRECTION = PD.DIRECTION

var current_index setget set_current_index
var board

onready var spatial_indicator = $Indicator

func setup(board):
	self.board = board
	disable_input()

func set_current_index(index):
	current_index = index

func enable_input():
	set_process(true)
	set_process_unhandled_input(true)

func disable_input():
	spatial_indicator.visible = false
	set_process(false)
	set_process_unhandled_input(false)

func _unhandled_input(event):
	if event.is_pressed():
		spatial_indicator.visible = true
		if event.is_action('ui_accept') : select_path_from_index()
		if event.is_action('ui_up') : move_current_index(DIRECTION['N'])
		if event.is_action('ui_down') : move_current_index(DIRECTION['S'])
		if event.is_action('ui_left') : move_current_index(DIRECTION['W'])
		if event.is_action('ui_right') : move_current_index(DIRECTION['E'])

func select_path_from_index():
	board.get_path_cell(current_index).press_path()

func _process(delta: float):
	if board:
		var target_pos =  board.map_to_world(current_index.x, 0, current_index.y)
		spatial_indicator.translation = target_pos

func move_current_index(dir: Vector2):
	var new_pos = current_index + dir
	if board.index_in_board(new_pos):
		# Move to next index
		self.current_index = new_pos
	else:
		# Wrap around the board
		self.current_index = new_pos - (dir * board.board_size)
