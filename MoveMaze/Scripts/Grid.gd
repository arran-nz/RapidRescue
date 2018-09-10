extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

var grid_size = Vector2(9,9)
var map_size = Vector2(7,7)
var path_cells
var injectors = []


var _tile_padding

signal injectors_ready

				
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
	path_cells = _board_generator.gen_path(grid_size, map_size, tile_size, self)
	
	_spawn_injectors()


func _spawn_injectors():
	pass
	
	var x_indices = []
	for x in range(map_size.x):
		if path_cells[x][0].moveable:
			x_indices.append(x)
			
	var y_indices = []
	for y in range(map_size.y):
		if path_cells[0][y].moveable:
			y_indices.append(y)
	
	var NW = world_to_map((path_cells[0][0].position))
	var SW = world_to_map((path_cells[0][map_size.y - 1].position))
	
	#NORTH AND SOUTH SIDES
	for x_i in x_indices:
		
		var n_index = Vector2(NW.x + x_i, NW.y + DIRECTION.N.y)
		var temp_north_inj = obj_injector.instance()
		temp_north_inj.position = map_to_world(n_index) + half_tile_size
		
		temp_north_inj.init(DIRECTION.S, x_i)
		injectors.append(temp_north_inj)
		add_child(temp_north_inj)
		
		var s_index = Vector2(NW.x + x_i, NW.y + (map_size.y - 1) + DIRECTION.S.y)
		var temp_south_inj = obj_injector.instance()
		temp_south_inj.position = map_to_world(s_index) + half_tile_size
		
		temp_south_inj.init(DIRECTION.N, x_i)
		injectors.append(temp_south_inj)
		add_child(temp_south_inj)
	
	#EAST AND WEST SIDES
	for y_i in y_indices:
		var e_index = Vector2(NW.x + (map_size.x - 1) + DIRECTION.E.x, NW.y + y_i)
		var temp_east_inj = obj_injector.instance()
		temp_east_inj.position = map_to_world(e_index) + half_tile_size
		
		temp_east_inj.init(DIRECTION.W, y_i)
		injectors.append(temp_east_inj)
		add_child(temp_east_inj)
		
		var w_index = Vector2(NW.x + DIRECTION.W.x, NW.y + y_i)
		var temp_west_inj = obj_injector.instance()
		temp_west_inj.position = map_to_world(w_index) + half_tile_size

		temp_west_inj.init(DIRECTION.E, y_i)
		injectors.append(temp_west_inj)
		add_child(temp_west_inj)
		
	emit_signal("injectors_ready", injectors)

func inject_path(index, dir, path_item):
	var line
	
	if dir == DIRECTION.S \
	or dir == DIRECTION.N:
		line = _get_col(index)
	else:
		line = _get_row(index)
		
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
	for x in range(map_size.x):
		for y in range(map_size.y):
			var temp_cell = path_cells[x][y]
			if temp_cell.index.x == x_index:
				col.append(temp_cell)
	
	return col
	
func _get_row(y_index):
	var row = []	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var temp_cell = path_cells[x][y]
			if temp_cell.index.y == y_index:
				row.append(temp_cell)
	
	return row
	
func _in_board(index):
	if index.x < map_size.x and index.x >= 0:
		if index.y < map_size.y and index.y >= 0:
			return true
	return false	
	
func _in_grid(g_pos):
	if g_pos.x < grid_size.x and g_pos.x >= 0:
		if g_pos.y < grid_size.y and g_pos.y >= 0:
			return true
	return false	