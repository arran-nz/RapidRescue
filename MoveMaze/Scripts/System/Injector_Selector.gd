extends Node

var current_index = 0
var board
var active setget _set_active

var _input_listening


func setup(board, start_active):
	self.board = board
	self.active = start_active
	
func _set_active(value):
	if value:
		if !_input_listening: _sub_inputs()
		board.injectors[current_index].hovered = true
	else:
		if _input_listening: _unsub_inputs()
		board.injectors[current_index].hovered = false
	
	active = value

func _sub_inputs():
	_input_listening = true
	InputManager.subscribe('select', self, 'select_injector_from_index')
	InputManager.subscribe('left', self, 'move_left')
	InputManager.subscribe('right', self, 'move_right')
	
func _unsub_inputs():
	_input_listening = false
	InputManager.unsubscribe('select', self, 'select_injector_from_index')
	InputManager.unsubscribe('left', self, 'move_left')
	InputManager.unsubscribe('right', self, 'move_right')

func select_injector_from_index():
	board.injectors[current_index].press_injector()
	
func move_left():
	move_current_index(-1)
	
func move_right():
	move_current_index(1)

func move_current_index(dir):
	# If on the bottom half of the board, flip the direction
	var quater = floor(board.injectors.size()  / 4)
	if current_index < (quater * 3) && current_index > quater - 1:
		dir *= -1
	
	var new_index = get_injector_index_wrapping(current_index, dir)
	
	if board.injectors[new_index].disabled:
		# Skip this injector and move to next index
		new_index = get_injector_index_wrapping(new_index, dir)
		
	board.injectors[current_index].hovered = false
	board.injectors[new_index].hovered = true
	current_index = new_index
	
func get_injector_index_wrapping(index, dir):
	var next_logical_pos = index + dir
	if next_logical_pos < board.injectors.size() and next_logical_pos >= 0:
		return next_logical_pos
	else:
		if dir > 0:
			return 0
		else:
			return board.injectors.size() - 1
