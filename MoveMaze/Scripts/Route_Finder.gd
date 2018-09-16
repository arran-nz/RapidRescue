extends Node

var board_obj

func init(board_obj):
	self.board_obj = board_obj

func get_route(start_path, end_path):
		
	var path_success = false
	var open_set = []
	open_set.append(start_path)
	var closed_set = []
	
	while len(open_set) > 0:
		
		var current_path = open_set.pop_front()
		closed_set.append(current_path)
		
		if current_path == end_path:
			print("Route Found")
			path_success = true
			break
			
		for n in _get_nextdoor_connected_neighbors(current_path):
			if closed_set.has(n):
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
	
	route.append(start_path)
	route.invert()
	
	return route
	
func _get_dist(path_a, path_b):
	
	var dx = abs(path_a.index.x - path_b.index.x)
	var dy = abs(path_a.index.y - path_b.index.y)
	
	return min(dx, dy) * 14 + abs(dx - dy) * 10


func get_reach(path):
	"""If found, will return list of tiles that are connected - Therefore reachable"""

	var reach = []
	reach.append(path)
	var neighbors = _get_nextdoor_connected_neighbors(path)

	# This is trash - make it better
	for n in neighbors:
		var extended_family = _get_nextdoor_connected_neighbors(n)
		for f in extended_family:
			if !neighbors.has(f):
				neighbors.append(f)
			if !reach.has(f):
				reach.append(f)
				
	return reach
	
func _get_nextdoor_neighbors(path):
	"""Return neighbors that the current path `points` to."""
	var neighbors = []
	for con in path.connections:
		if path.connections[con]:
			var dir = board_obj.DIRECTION[con]
			var n = board_obj.get_path(path.index + dir)
			if n != null:
				neighbors.append(n)
	return neighbors
	
func _get_nextdoor_connected_neighbors(path):
	"""Return neightbors that this path connected with."""
	var neighbors = _get_nextdoor_neighbors(path)
				
				
	var connected = []
	
	for n in neighbors:
		for n_con in n.connections:
			if n.connections[n_con]:
				if _get_nextdoor_neighbors(n).has(path):
					if !connected.has(n): connected.append(n)

	return connected
