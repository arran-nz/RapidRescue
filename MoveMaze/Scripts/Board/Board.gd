# Board - Store and maintain all `PATHS` and `ACTORS`.
# Responsile for every interaction on the playing board.

extends GridMap

var tile_size = get_cell_size()

var path_cells = []

const MAX_ACTORS = 4
var actors = []

signal board_paths_updated
signal disable_injector

const PD = preload('res://Scripts/Board/Definitions.gd').PathData
const DIRECTION = PD.DIRECTION
	
var obj_actor = preload("res://Objects/3D/Actor.tscn")

var _path_gen_res = load("res://Scripts/Board/Path_Generator.gd")
var _route_finder_res = load("res://Scripts/Board/Route_Finder.gd")

var route_finder = _route_finder_res.new(funcref(self, "get_path"))

var _path_generator
var board_size

var initialized = false
		
func setup_from_dict(map_data):
	_path_generator = _path_gen_res.new(map_data['map'], map_data['hand'])
	board_size = _path_generator.MAP_SIZE
	path_cells = _path_generator.path_cells
	_spawn_path_cells()
	_spawn_actors(map_data['actors'])
	_center_board()
	initialized = true

func setup_new_game(actor_count):
	_path_generator = _path_gen_res.new()
	board_size = _path_generator.MAP_SIZE
	path_cells = _path_generator.path_cells
	_spawn_path_cells()
	_spawn_new_actors(actor_count)
	_center_board()
	initialized = true

func get_repr():
	"""Return map representation."""
	var path_repr = []
	var actor_repr = []

	for p in path_cells:
		path_repr.append(p.get_repr())

	for a in actors:
		actor_repr.append(a.get_repr())

	return {
		'map' : path_repr,
		'actors' : actor_repr,
	}
	
func get_and_spawn_extra_path():
	var extra_path = _path_generator.extra_path
	add_child(extra_path)
	return extra_path

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
	var path = open_cells[x]
	var collectable = _path_generator.obj_collectable.instance()
	path.store_collectable(collectable)

func request_actor_movement(target_path, actor):
	var start_path = actor.active_path
	
	if start_path == target_path:
		print('Turn Skipped')
		return true
	
	var route = route_finder.get_route(start_path, target_path)
	
	if route != null:
		if len(route) >= 1:
			actor.set_route(route)
			return true

	return false

func request_actor_reach(actor):
	return route_finder.get_reach(actor.active_path)

func get_path_from_world(world_pos):
	breakpoint
	# Map position relative to board
	var pos  = (world_pos - self.position)
	
	var index = world_to_map(pos)
	return get_path(index)

func get_path(index):
	if index_in_board(index):
		for item in path_cells:
			if item.index == index:
				return item

func _center_board():
	var x = (tile_size.x * board_size.x) / 2
	var z = (tile_size.y * board_size.y) / 2
	translation = Vector3(-x, 0, -z) 

func inject_path(inject_index, dir, injected_path):
	
	var disabled_inj_board_index = inject_index + (dir * board_size) - dir
	emit_signal('disable_injector', disabled_inj_board_index)
	
	# Set World Target
	var world_target = map_to_world(inject_index.x, 0, inject_index.y)
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
		if index_in_board(new_path_index):
			_move_path(current_path, new_path_index)
		else:
			# Check if an actor is riding this current path
			for a in actors:
				if a.active_path == current_path:
					a.translation = injected_path.translation
					a.active_path = injected_path
		
			#Collect the path
			ejected_path = current_path
			# Set target to off the board
			ejected_path.set_target(map_to_world(new_path_index.x, 0, new_path_index.y))
	
	path_cells.erase(ejected_path)
	emit_signal('board_paths_updated')
	return ejected_path

func _spawn_path_cells():
	for cell in path_cells:
		cell.translation = map_to_world(cell.index.x, 0, cell.index.y)
		add_child(cell)

func _spawn_actors(actor_data):
	"""Spawn actors from a defined dictionary."""
	for a in actor_data:
		var index = Vector2( a.index_x, a.index_y)
		var actor = obj_actor.instance()
		actor.setup(a.id, get_path(index), a.people)
		add_child(actor)
		actors.append(actor)

func _spawn_new_actors(count):
	"""Calculate and spawn actors."""
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

func _move_path(path, new_index):
	var pos = map_to_world(new_index.x, 0, new_index.y)
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

func index_in_board(index):
	if index.x < board_size.x and index.x >= 0:
		if index.y < board_size.y and index.y >= 0:
			return true
	return false
