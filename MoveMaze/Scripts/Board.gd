extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

const board_size = Vector2(7,7)
var path_cells = []
var injectors = []

signal signal_hand

				
var DIRECTION = {
				'N' : Vector2(0, -1),
				'E' : Vector2(1, 0),
				'S' : Vector2(0, 1),
				'W' : Vector2(-1, 0),
	}
	

# Load the class resource when calling new().
onready var obj_path = preload("res://Objects/Path.tscn")
onready var obj_injector = preload("res://Objects/Path_Injector_Btn.tscn")
var _board_gen_res = load("res://Scripts/BoardGenerator.gd")

func _ready():

	var _board_generator = _board_gen_res.new()		
	path_cells = _board_generator.gen_path(board_size, tile_size, self)
	
	_spawn_injectors()
	
	var extra_path = _board_generator.get_path_tile(Vector2(-1,-1), '', obj_path)
	emit_signal("signal_hand", injectors, extra_path)


func _spawn_injectors():
	pass
	
	var north_row = _get_row(0)
	var x_indices = []
	for path in north_row:
		if path.moveable:
			x_indices.append(path.index.x)
	
	var west_col = _get_col(0)		
	var y_indices = []
	for path in west_col:
		if path.moveable:
			y_indices.append(path.index.y)
	
	var NW = world_to_map(path_cells[0].position)
	
	#NORTH AND SOUTH SIDES
	for x_i in x_indices:
		
		var n_index = Vector2(NW.x + x_i, NW.y + DIRECTION.N.y)
		var temp_north_inj = obj_injector.instance()
		temp_north_inj.position = map_to_world(n_index) + half_tile_size
		
		temp_north_inj.init(Vector2(x_i, 0), DIRECTION.S)
		injectors.append(temp_north_inj)
		add_child(temp_north_inj)
		
		var s_index = Vector2(NW.x + x_i, NW.y + (board_size.y - 1) + DIRECTION.S.y)
		var temp_south_inj = obj_injector.instance()
		temp_south_inj.position = map_to_world(s_index) + half_tile_size
		
		temp_south_inj.init(Vector2(x_i, board_size.y), DIRECTION.N)
		injectors.append(temp_south_inj)
		add_child(temp_south_inj)
	
	#EAST AND WEST SIDES
	for y_i in y_indices:
		var e_index = Vector2(NW.x + (board_size.x - 1) + DIRECTION.E.x, NW.y + y_i)
		var temp_east_inj = obj_injector.instance()
		temp_east_inj.position = map_to_world(e_index) + half_tile_size
		
		temp_east_inj.init(Vector2(0, y_i), DIRECTION.W)
		injectors.append(temp_east_inj)
		add_child(temp_east_inj)
		
		var w_index = Vector2(NW.x + DIRECTION.W.x, NW.y + y_i)
		var temp_west_inj = obj_injector.instance()
		temp_west_inj.position = map_to_world(w_index) + half_tile_size

		temp_west_inj.init(Vector2(board_size.x, y_i), DIRECTION.E)
		injectors.append(temp_west_inj)
		add_child(temp_west_inj)

func inject_path(index, dir, path_item):
	var line
	
	if dir == DIRECTION.S \
	or dir == DIRECTION.N:
		line = _get_col(index.x)
	else:
		line = _get_row(index.y)
		
	for path in line:
		_move_path(path, dir)
		
func _move_path(path, dir):
	
	var index = path.index + dir
	var pos = path.position + (tile_size * dir)
	if !_in_board(index):
		match dir:
			DIRECTION.N:
				print("N")
			DIRECTION.E:
				print("E")
			DIRECTION.S:
				print("S")
			DIRECTION.W:
				print("W")
		
	path.set_target(pos)

	path.update_index(index)
			
func _get_col(x_index):
	var col = []
	for item in path_cells:
			if item.index.x == x_index:
				col.append(item)
	
	return col
	
func _get_row(y_index):
	var row = []	
	for item in path_cells:
		if item.index.y == y_index:
			row.append(item)
	
	return row
	
func _in_board(index):
	if index.x < board_size.x and index.x >= 0:
		if index.y < board_size.y and index.y >= 0:
			return true
	return false	