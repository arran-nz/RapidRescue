extends Node

const PD = preload('res://Scripts/Board/Definitions.gd').PathData
const DIRECTION = PD.DIRECTION

var current_index setget set_current_index
var board
var active setget _set_active

onready var spatial_indicator = $Indicator

func _ready():
	self.active = false

func setup(board, start_active : bool):
	self.board = board
	self.active = start_active

func set_current_index(index):
	var f = board.index_has_actor(index) or board.index_has_path_with_collectable(index)
	spatial_indicator.visible = !f
	current_index = index

func _set_active(value : bool):
	spatial_indicator.visible = value
	set_process(value)
	set_process_unhandled_input(value)
	active = value

func _unhandled_input(event):
	if event.is_pressed():
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
