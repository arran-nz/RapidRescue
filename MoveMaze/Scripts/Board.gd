extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

const board_size = Vector2(7,7)
var path_cells = []
var injectors = []

var actors = []

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
onready var obj_actor = preload("res://Objects/Actor.tscn")

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

	_add_actor(get_path(Vector2()))

	emit_signal("board_ready")

func board_interaction(event):
	
	_remove_temp_path_properties()
	
	var actor = actors[0]
	var start_path = get_path(world_to_map(actor.position))
	var end_path = get_path_from_world(event.position)
	print("Index: " + str(end_path.index))
	
	var route = route_finder.get_route(start_path, end_path)
	
	if route != null:
		if len(route) > 1:
			actor.set_route(route)
			
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

func inject_path(inject_index, dir, path, collect_method):
	_remove_temp_path_properties()
	
	#Enable All Injectors
	for inj in injectors:
		inj.disabled = false
	
	#Disable a Injector
	var disabled_inj_index = inject_index + (dir * board_size) - dir
	_get_injector(disabled_inj_index).disabled = true
	
	# Set World Target
	var world_target = map_to_world(inject_index) + half_tile_size
	path.set_target(world_target, false)
	
	#Update index to injection location
	path.update_index(inject_index)
	print(inject_index)
	
	#Get Existing Line without new path
	var exsiting_line = []
	
	if dir == DIRECTION.S \
	or dir == DIRECTION.N:
		exsiting_line = _get_col(inject_index.x)
	else:
		exsiting_line = _get_row(inject_index.y)
		
	#Add New Path To Path_Cells Array
	path_cells.append(path)
		
	# For every path in line
	for current_path in exsiting_line:
		# Get the new path index
		var new_path_index = current_path.index + dir
		
		# If in board, move it
		if _in_board(new_path_index):
			_move_path(current_path, new_path_index)
		else:
			# Check if an actor is riding this current path
			for a in actors:
				if a.active_path == current_path:
					a.position = path.position
					a.active_path = path
		
			#Collect the path
			collect_method.call_func(current_path)
			path_cells.erase(current_path)

func _add_actor(spawn_path):
	var actor = obj_actor.instance()
	actor.active_path = spawn_path
	add_child(actor)
	actors.append(actor)

func _remove_temp_path_properties():
	for path in path_cells:
		path.properties.remove('pallete_index')

func _spawn_injectors():
	
	# Get Indices of only moveable paths along north and west rows
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
	
	var NW = Vector2(north_row[0].index)
	
	#NORTH AND SOUTH SIDES
	for x_i in x_indices:
		var new_north_inj = obj_injector.instance()
		var new_south_inj = obj_injector.instance()
		
		var n_index = Vector2(NW.x + x_i, NW.y + DIRECTION.N.y)
		new_north_inj.position = map_to_world(n_index) + half_tile_size
		new_north_inj.init(Vector2(x_i, n_index.y) + DIRECTION.S, DIRECTION.S)

		var s_index = Vector2(NW.x + x_i, NW.y + (board_size.y - 1) + DIRECTION.S.y)
		new_south_inj.position = map_to_world(s_index) + half_tile_size
		new_south_inj.init(Vector2(x_i, s_index.y) + DIRECTION.N, DIRECTION.N)
		
		injectors.append(new_north_inj)
		injectors.append(new_south_inj)
		add_child(new_north_inj)
		add_child(new_south_inj)
	
	#EAST AND WEST SIDES
	for y_i in y_indices:
		var new_east_inj = obj_injector.instance()
		var new_west_inj = obj_injector.instance()
		
		var e_index = Vector2(NW.x + (board_size.x - 1) + DIRECTION.E.x, NW.y + y_i)
		new_east_inj.position = map_to_world(e_index) + half_tile_size
		new_east_inj.init(Vector2(e_index.x, y_i) + DIRECTION.W , DIRECTION.W)

		var w_index = Vector2(NW.x + DIRECTION.W.x, NW.y + y_i)
		new_west_inj.position = map_to_world(w_index) + half_tile_size
		new_west_inj.init(Vector2(w_index.x, y_i) + DIRECTION.E, DIRECTION.E)
		
		injectors.append(new_east_inj)
		injectors.append(new_west_inj)
		add_child(new_east_inj)
		add_child(new_west_inj)

func _move_path(path, new_index):
	var pos = map_to_world(new_index) + half_tile_size
	path.update_index(new_index)
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

func _get_injector(inj_board_index):
	for inj in injectors:
		if inj.inj_board_index == inj_board_index:
			return inj

func _in_board(index):
	if index.x < board_size.x and index.x >= 0:
		if index.y < board_size.y and index.y >= 0:
			return true
	return false	