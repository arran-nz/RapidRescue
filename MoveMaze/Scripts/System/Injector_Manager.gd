extends Spatial

const PD = preload('res://Scripts/Board/Definitions.gd').PathData
const DIRECTION = PD.DIRECTION

var obj_injector = preload("res://Objects/3D/Injector.tscn")

var injectors = []

var current_index = 0
var board
var active setget _set_active

func _ready():
	self.active = false

func setup(board):
	self.board = board
	translation = board.translation
	_spawn_injectors()
	board.connect('disable_injector', self, 'disable_injector')

func _set_active(value):
	if injectors:
		injectors[current_index].hovered = value

	set_process_unhandled_input(value)
	active = value

func _unhandled_input(event):
	if event.is_pressed():
		if event.is_action('ui_accept') : press_injector_from_index()
		if event.is_action('ui_left') : cycle_current_index(-1)
		if event.is_action('ui_right') : cycle_current_index(1)

func press_injector_from_index():
	injectors[current_index].press_injector()
	
func disable_injector(inj_board_index):
	#Enable All Disabled Injectors and Disable appropriate
	for inj in injectors:
		if inj.disabled:
			inj.disabled = false
		if inj.inj_board_index == inj_board_index:
			inj.disabled = true

func cycle_current_index(dir):
	var new_index = _get_injector_index_wrapping(current_index, dir)
	
	if injectors[new_index].disabled:
		# Skip this injector and move to next index
		new_index = _get_injector_index_wrapping(new_index, dir)
		
	injectors[current_index].hovered = false
	injectors[new_index].hovered = true
	current_index = new_index
	
func _get_injector_index_wrapping(index, dir):
	var next_logical_pos = index + dir
	if next_logical_pos < injectors.size() and next_logical_pos >= 0:
		return next_logical_pos
	else:
		if dir > 0:
			return 0
		else:
			return injectors.size() - 1

func _spawn_injectors():
	# Get Indices of only moveable paths along north and west rows
	var north_row = board._get_row(0)
	var x_indices = []
	for path in north_row:
		if path.moveable:
			x_indices.append(path.index.x)
	
	var west_col = board._get_col(0)
	var y_indices = []
	for path in west_col:
		if path.moveable:
			y_indices.append(path.index.y)
	
	var NW = Vector2(north_row[0].index)
	
	# NORTH ROW
	for x_i in x_indices:
		var new_north_inj = obj_injector.instance()
		var n_index = Vector2(NW.x + x_i, NW.y + DIRECTION.N.y)
		new_north_inj.translation = board.map_to_world(n_index.x, 0, n_index.y)
		new_north_inj.setup(Vector2(x_i, n_index.y) + DIRECTION.S, DIRECTION.S)
		injectors.append(new_north_inj)
		add_child(new_north_inj)
		
	# EAST ROW
	for y_i in y_indices:
		var new_east_inj = obj_injector.instance()
		var e_index = Vector2(NW.x + (board.board_size.x - 1) + DIRECTION.E.x, NW.y + y_i)
		new_east_inj.translation = board.map_to_world(e_index.x, 0, e_index.y)
		new_east_inj.setup(Vector2(e_index.x, y_i) + DIRECTION.W , DIRECTION.W)
		injectors.append(new_east_inj)
		add_child(new_east_inj)
	
	x_indices.invert()
	y_indices.invert()
	
	# SOUTH ROW
	for x_i in x_indices:
		var new_south_inj = obj_injector.instance()
		var s_index = Vector2(NW.x + x_i, NW.y + (board.board_size.y - 1) + DIRECTION.S.y)
		new_south_inj.translation = board.map_to_world(s_index.x, 0, s_index.y)
		new_south_inj.setup(Vector2(x_i, s_index.y) + DIRECTION.N, DIRECTION.N)
		injectors.append(new_south_inj)
		add_child(new_south_inj)
		
	# WEST ROW
	for y_i in y_indices:
		var new_west_inj = obj_injector.instance()
		var w_index = Vector2(NW.x + DIRECTION.W.x, NW.y + y_i)
		new_west_inj.translation = board.map_to_world(w_index.x, 0, w_index.y)
		new_west_inj.setup(Vector2(w_index.x, y_i) + DIRECTION.E, DIRECTION.E)
		injectors.append(new_west_inj)
		add_child(new_west_inj)