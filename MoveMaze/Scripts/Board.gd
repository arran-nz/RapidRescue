extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

const board_size = Vector2(7,7)
var path_cells = []
var injectors = []

signal signal_hand
signal board_ready

const DIRECTION = {
				'N' : Vector2(0, -1),
				'E' : Vector2(1, 0),
				'S' : Vector2(0, 1),
				'W' : Vector2(-1, 0),
	}
	

# Load the class resource when calling new().
onready var obj_path = preload("res://Objects/Path.tscn")
onready var obj_injector = preload("res://Objects/Path_Injector_Btn.tscn")

var _path_gen_res = load("res://Scripts/Path_Generator.gd")
var _route_finder_res = load("res://Scripts/Route_Finder.gd")

var route_finder = _route_finder_res.new(DIRECTION, funcref(self, "get_path"))

func _ready():

	var _path_generator = _path_gen_res.new()		
	path_cells = _path_generator.gen_path(board_size, tile_size, self)
	
	_spawn_injectors()
	
	var extra_path = _path_generator.get_path_tile(Vector2(), '', obj_path)
	emit_signal("signal_hand", injectors, extra_path)
	add_child(extra_path)

	emit_signal("board_ready")

func _remove_temp_path_properties():
	for path in path_cells:
		path.properties.remove('pallete_index')

func board_interaction(event):
	
	_remove_temp_path_properties()
	

	
	var start_path = get_path_from_world(event.position)
	var end_path = get_path(Vector2())
	
	var route = route_finder.get_route(start_path, end_path)
	
	if route != null:
		for path in route:
			path.properties.set('pallete_index', 4)
	else:
		var reach = route_finder.get_reach(start_path)
		for path in reach:
			path.properties.set('pallete_index', 1)

func get_path_from_world(world_pos):
	# Map position reletive to board
	var pos  = world_pos - self.position
	var index = world_to_map(pos)
	return get_path(index)

func get_path(index):
	if _in_board(index):
		for item in path_cells:
			if item.index == index:
				return item

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
		
		temp_north_inj.init(Vector2(x_i, n_index.y), DIRECTION.S)
		injectors.append(temp_north_inj)
		add_child(temp_north_inj)
		
		var s_index = Vector2(NW.x + x_i, NW.y + (board_size.y - 1) + DIRECTION.S.y)
		var temp_south_inj = obj_injector.instance()
		temp_south_inj.position = map_to_world(s_index) + half_tile_size
		
		temp_south_inj.init(Vector2(x_i, s_index.y), DIRECTION.N)
		injectors.append(temp_south_inj)
		add_child(temp_south_inj)
	
	#EAST AND WEST SIDES
	for y_i in y_indices:
		var e_index = Vector2(NW.x + (board_size.x - 1) + DIRECTION.E.x, NW.y + y_i)
		var temp_east_inj = obj_injector.instance()
		temp_east_inj.position = map_to_world(e_index) + half_tile_size
		
		temp_east_inj.init(Vector2(e_index.x, y_i), DIRECTION.W)
		injectors.append(temp_east_inj)
		add_child(temp_east_inj)
		
		var w_index = Vector2(NW.x + DIRECTION.W.x, NW.y + y_i)
		var temp_west_inj = obj_injector.instance()
		temp_west_inj.position = map_to_world(w_index) + half_tile_size

		temp_west_inj.init(Vector2(w_index.x, y_i), DIRECTION.E)
		injectors.append(temp_west_inj)
		add_child(temp_west_inj)

func inject_path(index, dir, path_item, collect_method):
	
	_remove_temp_path_properties()
	
	for inj in injectors:
		inj.hot = false
	
	# Set World Target
	var world_target = map_to_world(index) + half_tile_size
	path_item.set_target(world_target, false)
	
	#Update index to injection location
	path_item.update_index(index)
	
	#Add To Path_Cells Array
	path_cells.append(path_item)
	
	#Move Line in Direction
	var line
	if dir == DIRECTION.S \
	or dir == DIRECTION.N:
		line = _get_col(index.x)
	else:
		line = _get_row(index.y)
			
	for path in line:
		_move_path(path, dir, collect_method)

func _move_path(path, dir, collect_method):
	
	var index = path.index + dir
	#var pos = path.position + (tile_size * dir)
	var pos = map_to_world(index) + half_tile_size
	
	#If the path item's index has moved of the board, collect it.
	if !_in_board(index):
		collect_method.call_func(path)
		path_cells.erase(path)
		_get_injector(path.index + dir).hot = true
	else:
		path.update_index(index)
		path.set_target(pos)	

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

func _get_injector(index):
	for inj in injectors:
		if inj.inj_board_index == index:
			return inj

func _in_board(index):
	if index.x < board_size.x and index.x >= 0:
		if index.y < board_size.y and index.y >= 0:
			return true
	return false	