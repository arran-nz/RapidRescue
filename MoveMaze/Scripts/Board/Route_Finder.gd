# Route_Finder - Use A-STAR to find the shortest route between two `PATH` items.

extends Resource

const DIRECTION = preload('res://Scripts/Board/Definitions.gd').PathData.DIRECTION
var get_path

const SIMPLIFY_ROUTE = false

func _init(get_path):
	self.get_path = get_path

func get_route(start_path, end_path):
	"""Return a route from start to end. If possible."""

	var path_success = false
	var open_set = []
	open_set.append(start_path)
	var visited_set = []

	while len(open_set) > 0:

		var current_path = open_set.pop_front()
		visited_set.append(current_path)

		if current_path == end_path:
			path_success = true
			break

		for n in _get_connected_neighbors(current_path):
			if visited_set.has(n):
				continue

			var new_movement_cost_to_n = current_path.traversal.g_cost + _get_dist(current_path, n)
			if (new_movement_cost_to_n < n.traversal.g_cost or !open_set.has(n)):
				n.traversal.g_cost = new_movement_cost_to_n
				n.traversal.h_cost = _get_dist(n, end_path)
				n.traversal.parent = current_path

				if !open_set.has(n):
					open_set.append(n)

	if path_success:
		return _retrace_route(start_path, end_path)
	else:
		print("Path Not Found")

func _retrace_route(start_path, end_path):
	var route = []
	var current_path = end_path

	while current_path != start_path:
		route.append(current_path)
		current_path = current_path.traversal.parent

	if SIMPLIFY_ROUTE:
		route.append(start_path)
		route = _simplify_route(route)

	route.invert()
	return route

func _simplify_route(route):
	var simple_route = []
	var old_dir = Vector2(0,0)

	for i in range(1, route.size()):
		var x_dif = route[i-1].index.x - route[i].index.x
		var y_dif = route[i-1].index.y - route[i].index.y
		var new_dir = Vector2(x_dif, y_dif)
		if old_dir != new_dir:
			simple_route.append(route[i-1])
		old_dir = new_dir

	return simple_route

func _get_dist(path_a, path_b):

	var dx = abs(path_a.index.x - path_b.index.x)
	var dy = abs(path_a.index.y - path_b.index.y)

	return min(dx, dy) * 14 + abs(dx - dy) * 10


func get_reach(path):
	"""If found, will return list of tiles that are connected - Therefore reachable"""
	var open_set = []
	var visited_set = []
	open_set.append(path)

	while len(open_set) > 0:
		var current_path = open_set.pop_front()
		visited_set.append(current_path)

		for n in _get_connected_neighbors(current_path):
			if !visited_set.has(n):
				open_set.append(n)


	return visited_set

func _get_connected_neighbors(path):

	var connected_neighbors = []
	var relevant_neighbors = []

	# Loop through the connections where the value is true (connected)
	for c in path.connections:
		if path.connections[c]:
			# Get that direction in vector form
			var dir = DIRECTION[c]
			# Get the path it's trying to connect with
			var n = get_path.call_func(path.index + dir)
			# If there's a path, add it for later
			if n != null:
				relevant_neighbors.append(n)

	# Loop through relevant neighbors
	for n in relevant_neighbors:
		# Loop through the connections where the value is true (connected)
		for c in n.connections:
			if n.connections[c]:
				# Get the direction of the path and invert it
				var dir = DIRECTION[c] * -1
				# Get the vector diff
				var rel_dir = n.index - path.index
				# If they're the same, they're connected
				if dir == rel_dir:
					connected_neighbors.append(n)

	return connected_neighbors
