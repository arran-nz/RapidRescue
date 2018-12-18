# Board - Store and maintain all `PATHS`, `INJECTORS` and `ACTORS`.
# Responsile for every interaction on the playing board.

extends TileMap

var tile_size = get_cell_size()

const board_size = Vector2(7,7)
var path_cells = []
var injectors = []

const MAX_ACTORS = 4
var actors = []

signal extra_path_ready
signal board_ready
signal board_paths_updated

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

var _path_gen_res = load("res://Scripts/Board/Path_Generator.gd")
var _route_finder_res = load("res://Scripts/Board/Route_Finder.gd")

var route_finder = _route_finder_res.new(DIRECTION, funcref(self, "get_path"))

func _ready():	
	
	var _path_generator = _path_gen_res.new()
	path_cells = _path_generator.gen_path(board_size, self)
	
	#Injectors
	_spawn_injectors()

	# Extra Path
	var extra_path = _path_generator.get_moveable_path(Vector2(), obj_path)
	add_child(extra_path)
	emit_signal('extra_path_ready', extra_path)
	
	emit_signal('board_ready')

func spawn_collectable():
	
	var open_cells = []
	var closed_cells = []
	# Rule out cells are within reach of ALL actors

	for actor in actors:
		var reach = route_finder.get_reach(actor.active_path)
		for cell in reach:
			closed_cells.append(cell)
	
	# Add the remaining cells to the open list
	for cell in path_cells:
		if !closed_cells.has(cell):
			open_cells.append(cell)
	
	# Choose randomly from open cells
	var x = randi() % len(open_cells)
	open_cells[x].c_storage.store(1)

func spawn_actors(players):
	
	var count = len(players)
	
	# Don't add more actors than max
	if count > MAX_ACTORS:
		print("You can only have %s actors." % MAX_ACTORS)
		return

	# Ensure this function only runs if there isnt any exsisting actors
	if len(actors) > 0:
		print("Actors already exsist.")
		return

	#Create list of all spawn paths (Corners)
	var nw_path = get_path(Vector2())
	var ne_path = get_path(Vector2(board_size.x - 1, 0))
	var se_path = get_path(Vector2(board_size.x - 1, board_size.y -1))
	var sw_path = get_path(Vector2(0, board_size.y - 1))

	var corner_paths = []
	
	# If there are 2 desired actors, put them diagonal to each other
	if count == 2:
		if randi() % 2 == 1:
			corner_paths.append(nw_path)
			corner_paths.append(se_path)
		else:
			corner_paths.append(ne_path)
			corner_paths.append(sw_path)
	else:
		corner_paths.append(nw_path)
		corner_paths.append(ne_path)
		corner_paths.append(se_path)
		corner_paths.append(sw_path)

	# Iterate for the count of desired actors	
	for i in range(count):
		var actor = obj_actor.instance()
		actor.setup(i, corner_paths[i])
		add_child(actor)
		actors.append(actor)

func request_actor_movement(target_position, actor_index):
	
	if actor_index >= len(actors) or actor_index < 0:
		print("Incorrect Actor Index")
		return
	
	_remove_temp_path_properties()
	
	var actor = actors[actor_index]
	var start_path = actor.active_path
	var end_path = get_path_from_world(target_position)
	
	var route = route_finder.get_route(start_path, end_path)
	
	if route != null:
		if len(route) > 1:
		
			start_path.properties.set('pallete_index', 4)
			for path in route:
				path.properties.set('pallete_index', 4)

			#Discard first path on route as Actor does not need it
			route.pop_front()
			actor.set_route(route)
			
			return true
			
		elif len(route) == 1:
			return true
	
	return false

func request_actor_reach(actor_index):
	var actor = actors[actor_index]
	var actor_path = get_path(world_to_map(actor.position))
	return route_finder.get_reach(actor.active_path)

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

func inject_path(inject_index, dir, injected_path):
	_remove_temp_path_properties()
	
	#Enable All Injectors
	for inj in injectors:
		inj.disabled = false
	
	#Disable a Injector
	var disabled_inj_index = inject_index + (dir * board_size) - dir
	_get_injector(disabled_inj_index).disabled = true
	
	# Set World Target
	var world_target = map_to_world(inject_index)
	# Move to world target
	injected_path.set_target(world_target, false)
	
	#Update index to injection location
	injected_path.update_index(inject_index)
	print(inject_index)
	
	#Get Existing Line without new path
	var exsiting_line = []
	
	if dir == DIRECTION.S \
	or dir == DIRECTION.N:
		exsiting_line = _get_col(inject_index.x)
	else:
		exsiting_line = _get_row(inject_index.y)
		
	#Add New Path To Path_Cells Array
	path_cells.append(injected_path)
	
	var ejected_path
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
					a.position = injected_path.position
					a.active_path = injected_path
		
			#Collect the path
			ejected_path = current_path
			# Set target to off the board
			ejected_path.set_target(map_to_world(new_path_index))
	
	path_cells.erase(ejected_path)
	
	emit_signal('board_paths_updated')
	return ejected_path	

func _remove_temp_path_properties():
	for path in path_cells:
		path.properties.remove('pallete_index')
		path.properties.remove('test')

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
		new_north_inj.position = map_to_world(n_index)
		new_north_inj.init(Vector2(x_i, n_index.y) + DIRECTION.S, DIRECTION.S)

		var s_index = Vector2(NW.x + x_i, NW.y + (board_size.y - 1) + DIRECTION.S.y)
		new_south_inj.position = map_to_world(s_index)
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
		new_east_inj.position = map_to_world(e_index)
		new_east_inj.init(Vector2(e_index.x, y_i) + DIRECTION.W , DIRECTION.W)

		var w_index = Vector2(NW.x + DIRECTION.W.x, NW.y + y_i)
		new_west_inj.position = map_to_world(w_index)
		new_west_inj.init(Vector2(w_index.x, y_i) + DIRECTION.E, DIRECTION.E)
		
		injectors.append(new_east_inj)
		injectors.append(new_west_inj)
		add_child(new_east_inj)
		add_child(new_west_inj)

func _move_path(path, new_index):
	var pos = map_to_world(new_index)
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
