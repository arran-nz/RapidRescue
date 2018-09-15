extends Node

var board_obj

func init(board_obj):
	self.board_obj = board_obj

func _get_reach(path):
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
