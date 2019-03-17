# Path_Generator - Generate the board paths.

extends Resource

#Direction Representation
# N = North / Up
# E = East / Right
# S = South / Down
# W = West / Left

#Path Type Representation
# T = T-Insection
# I = Straight
# L = Corner

const MAP_SIZE = Vector2(7,7)

const PD = preload('res://Scripts/Board/Definitions.gd').PathData
const I = PD.INDEX
const C = PD.CONNECTIONS
const M = PD.MOVEABLE

const DEFAULT_MAP = [
				{C:'SE', M:0}, {M:1}, {C:'ESW', M:0}, {M:1}, {C:'ESW', M:0}, {M:1}, {C:'SW', M:0},
				{M:1}, {M:1}, {M:1}, {M:1}, {M:1}, {M:1}, {M:1},
				
				{C:'NES', M:0}, {M:1}, {C:'NES', M:0}, {M:1}, {C:'ESW', M:0}, {M:1}, {C:'NSW', M:0},
				{M:1}, {M:1}, {M:1}, {M:1}, {M:1}, {M:1}, {M:1},
				
				{C:'NES', M:0}, {M:1}, {C:'NEW', M:0}, {M:1}, {C:'NSW', M:0}, {M:1}, {C:'NWS', M:0},
				{M:1}, {M:1}, {M:1}, {M:1}, {M:1}, {M:1}, {M:1},
				
				{C:'NE', M:0}, {M:1}, {C:'NEW', M:0}, {M:1}, {C:'NEW', M:0}, {M:1}, {C:'NW', M:0},
	]

const PATH_VARIATIONS = { 
				'T' : ['ESW', 'NSW', 'NEW', 'NES'],
				'I' : ['NS', 'EW'],
				'L' : ['NE', 'SE', 'SW', 'NW'] 
	}

const PATH_DISTRIBUTION = {
				'T' : 6,
				'I' : 12,
				'L' : 16,
	}
	
var _map_data
var extra_path setget ,_get_extra_path
var path_cells setget ,_get_path_cells

var _available_paths  = []

var obj_collectable = preload("res://Objects/3D/Collectable.tscn")
var obj_path = preload("res://Objects/3D/Path.tscn")

func _init(map_data=null, extra_path_data=null):
	if map_data != null and extra_path_data != null:
		# If you define map_data
		_map_data = map_data
	else:
		# Else default map will load.
		_map_data = DEFAULT_MAP
		
		# Extend DEFAULT MAP.
		# Append indices as the order of the array is fixed.
		# Whereas the loaded Path array dictionay need's to store their individual indices.
		var x = 0
		var y = 0
		for count in range(_map_data.size()):
			x = int(count) % int(MAP_SIZE.x ) 
			if count > 0 and x == 0: y+=1
			_map_data[count][I] = Vector2(x,y)
			
		# Distribute and shuffle avaliable path types.
		_distribute_paths()
		extra_path_data = {C: _pop_distributed_path_type(), M:1}
		
	# Compute
	path_cells = _compute_path_cells()
	extra_path = _get_path(null, extra_path_data)
	
func _get_path_cells():
	return path_cells
	
func _get_extra_path():
	return extra_path
	
func _compute_path_cells():
	var path_cells = []
	for dict in _map_data:
		var path_tile = _get_path(_get_index(dict), dict)
		path_cells.append(path_tile)
	return path_cells

func _get_index(dict):
	var index
	if dict.has(I):
		# FOR DEFAULT MAP
		index = dict[I]
	elif dict.has(str(I)):
		# FOR JSON LOAD MAP
		# Convert string to Vector2()
		index = _str_to_vec2(dict[str(I)])
	else:
		print("ERR: Index not set")
		
	return index

func _get_path(index, content):
	var path_tile = obj_path.instance()
	var connections = {
			'N': false,
			'E': false,
			'S': false,
			'W': false
	}
	
	# Connection string eg "NESW"
	var connection_string
	if content.has(C):
		# FOR DEFAULT MAP
		connection_string = content[C]
	elif content.has(str(C)):
		# FOR JSON LOADED MAP
		connection_string = content[str(C)]
	else:
		connection_string = _pop_distributed_path_type()
	
	# Flip flag if CHAR is found in loaded connection_string
	for c in connection_string:
		connections[c] = true
	
	# Moveable flag
	var moveable
	if content.has(M):
		# FOR DEFAULT MAP
		moveable = bool(content[M])
	elif content.has(str(M)):
		# FOR JSON LOAD MAP
		moveable = bool(content[str(M)])
	else:
		print("ERR: Moveable flag not set")
		return

	if content.has(str(PD.COLLECTABLE)):
		var collectable = obj_collectable.instance()
		path_tile.setup(index, connections, moveable,collectable)
	else:
		path_tile.setup(index, connections, moveable)
	
	return path_tile

func _str_to_vec2(string):
	"""Input: `(0, 4)` Output: Vector2(0, 4)"""
	string = (string.substr(1, len(string)-2))
	var split = string.split(',')
	var vec2 = Vector2(float(split[0]), float(split[1]))
	return vec2

func _pop_distributed_path_type():
	if len(_available_paths ) > 0:
		var p_type = _available_paths.pop_back()
		var variation = rand_range(0, PATH_VARIATIONS[p_type].size())
		return PATH_VARIATIONS[p_type][variation]
	else:
		print("ERR: No more paths available.")

func _distribute_paths():
	randomize()
	var paths = []
	for type in PATH_DISTRIBUTION:
#warning-ignore:unused_variable
		for i in range(PATH_DISTRIBUTION[type]):
			paths.append(type)
	
	_available_paths  = _shuffleList(paths)

func _shuffleList(list):
    var shuffled_list = [] 
    var index_list = range(list.size())
#warning-ignore:unused_variable
    for i in range(list.size()):
        var x = randi()%index_list.size()
        shuffled_list.append(list[index_list[x]])
        index_list.remove(x)
    return shuffled_list