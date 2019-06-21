# Board - Store and maintain all `PATHS` and `ACTORS`.
# Responsile for every interaction on the playing board.

extends GridMap

var tile_size = get_cell_size()

var path_cells = []

const MAX_ACTORS = 4
var actors = []

signal passenger_returned
signal actor_updated
signal board_paths_updated
signal disable_injector

const PD = preload('res://Scripts/Board/Definitions.gd').PathData
const DIRECTION = PD.DIRECTION
const NUDGE_AMOUNT = 0.4

var obj_actor = preload("res://Objects/3D/Actor.tscn")


var route_finder = RouteFinder.new(funcref(self, "get_path_cell"))

var _path_generator
var board_size

var initialized = false

func setup_from_dict(map_data):
	_path_generator = PathGenerator.new(map_data['map'], map_data['hand'])
	board_size = _path_generator.MAP_SIZE
	path_cells = _path_generator.path_cells
	_spawn_path_cells()
	_spawn_actors(map_data['actors'])
	_center_camera()
	initialized = true

func setup_new(actor_count):
	_path_generator = PathGenerator.new()
	board_size = _path_generator.MAP_SIZE
	path_cells = _path_generator.path_cells
	_spawn_path_cells()
	_spawn_new_actors(actor_count)
	_center_camera()
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


func draw_grid():

	var color = Color(1, 0.996078, 0.996078, 0.184314)
	var width = 2

	var time = INF

	var z = 1.5
	var buffer = 0.5

	var x_min = -buffer
	var y_min = -buffer

	var x_max = (board_size.x * tile_size.x) + buffer
	var y_max = (board_size.y * tile_size.y) + buffer

	#Cols
	var start_pos = Vector3(x_min,z, y_min)
	var end_pos = Vector3(x_max, z, y_max)
	for x in range(board_size.x + 1):
		var x_pos = x * tile_size.x
		start_pos.x = x_pos
		end_pos.x = x_pos
		Draw3D.DrawLine(
			translation + start_pos,
			translation + end_pos,
			color,
			time,
			width)

	# Rows
	start_pos = Vector3(x_min,z, y_min)
	end_pos = Vector3(x_max, z, y_max)
	for y in range(board_size.y + 1):
		var y_pos = y * tile_size.z
		start_pos.z = y_pos
		end_pos.z = y_pos
		Draw3D.DrawLine(
			translation + start_pos,
			translation + end_pos,
			color,
			time,
			width)


func spawn_new_collectable():
	# Find the most suitable location and spawn a new collectable.
	var undersireable_cells = []
	var desired_cells = []
	var potential_cells = path_cells.duplicate()

	# Cells that are within reach are undesired
	for actor in actors:
		var reach = route_finder.get_reach(actor.active_path)
		for cell in reach:
			undersireable_cells.append(cell)
		# Rule out the home dock for active players
		potential_cells.erase(actor.home_dock)

	# Add the remaining cells to the open list
	for cell in potential_cells:
		if !undersireable_cells.has(cell):
			desired_cells.append(cell)

	var path
	if desired_cells.size() >= 1:
		# Choose randomly from open cells
		path = desired_cells[randi() % len(desired_cells)]
	else:
		# Choose randomly from potential cells
		path = potential_cells[randi() % len(potential_cells)]

	var collectable = _path_generator.obj_collectable.instance()
	path.store_collectable(collectable)

func request_actor_movement(target_path, actor):
	var route = route_finder.get_route(actor.active_path, target_path)
	if route != null:
		if route.size() >= 1:
			actor.set_route(route, target_path)
			return true

func check_actor_collisions(actor):
	# Soon to be Dead (STBD) Actor
	for other_actor in actors:
		if actor.active_path == other_actor.active_path \
		and other_actor != actor:
			other_actor.retreive_passengers()
			other_actor.active_path = other_actor.home_dock

	# Check home dock
	if actor.is_at_dock() and actor.get_passenger_count() > 0:
		var rescued_passengers = actor.retreive_passengers()
		for passenger in rescued_passengers:
			emit_signal("passenger_returned", actor.id)

	# Check for Collectable
	if actor.active_path.has_collectable and actor.has_seat():
		var item = actor.active_path.pickup_collectable()
		actor.add_passenger(item)
		# Spawn another collectable
		spawn_new_collectable()

	emit_signal("actor_updated")

func index_has_path_with_collectable(index):
	return get_path_cell(index).has_collectable

func index_has_actor(index):
	if index_get_actor(index) != null:
		return true
	return false

func index_get_actor(index):
	var path_cell = get_path_cell(index)
	for actor in actors:
		if actor.active_path == path_cell:
			return actor

func request_actor_reach(actor):
	return route_finder.get_reach(actor.active_path)

func get_path_cell(index):
	if index_in_board(index):
		for item in path_cells:
			if item.index == index:
				return item

func _center_camera():
	var x = (tile_size.x * board_size.x) / 2
	var z = (tile_size.y * board_size.y) / 2
	var offset = Vector3(x, 0, z)
	var cam = get_viewport().get_camera()
	cam.translation = Vector3(x, 10, z + 5)

func reset_path_translations(is_instant=false):
	for path in path_cells:
		path.set_target(map_to_world(path.index.x, 0, path.index.y), is_instant)

func nudge_line(index, dir):
	var line = get_line(index, dir)
	for path in line:
		path.set_target(get_nudge_pos(path.index, dir))

func get_nudge_pos(index, dir):
	var world_pos = map_to_world(index.x, 0, index.y)
	var nudge_vector = dir * NUDGE_AMOUNT
	return Vector3(
		world_pos.x + nudge_vector.x,
		world_pos.y,
		world_pos.z + nudge_vector.y
	)

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
	var exsiting_line = get_line(inject_index, dir)

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
		var index = Vector2(a.index_x, a.index_y)

		# TODO: Save and load HOME_DOCK this properly.
		var home_dock_index = index
		var active_path = get_path_cell(index)
		var home_dock_path = active_path
		var actor = obj_actor.instance()
		actor.setup(a.id, active_path, home_dock_path)
		actor.connect('final_target_reached', self, 'check_actor_collisions')
		add_child(actor)
		actors.append(actor)
		# Add Collectable People
		# TODO: SPAWN WITH AMOUNT OF A.PEOPLE
		print(a.people)

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
	var nw_path = get_path_cell(Vector2())
	var ne_path = get_path_cell(Vector2(board_size.x - 1, 0))
	var se_path = get_path_cell(Vector2(board_size.x - 1, board_size.y -1))
	var sw_path = get_path_cell(Vector2(0, board_size.y - 1))

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
		actor.setup(i, corner_paths[i], corner_paths[i])
		actor.connect('final_target_reached', self, 'check_actor_collisions')
		add_child(actor)
		actors.append(actor)

func _move_path(path, new_index):
	var pos = map_to_world(new_index.x, 0, new_index.y)
	path.update_index(new_index)
	path.set_target(pos)

func get_line(index, dir):
	var line = []
	if dir == DIRECTION.S \
	or dir == DIRECTION.N:
		return _get_col(index.x)
	else:
		return _get_row(index.y)

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
