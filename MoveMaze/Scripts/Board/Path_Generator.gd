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

enum {
	C, # Connections
	M, # Moveable
}
const PD = preload('res://Scripts/Board/Definitions.gd').PathData

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

var obj_path = preload("res://Objects/3D/Path_Block.tscn")

func _init(map_data=null, extra_path_connections=null):
	if map_data != null and extra_path_connections != null:
		# If you define map_data
		_map_data = map_data
	else:
		# Else default map will load.
		_map_data = DEFAULT_MAP
		print('DEFAULT')
		# Distribute and shuffle avaliable path types.
		_distribute_paths()
		extra_path_connections = _pop_distributed_path_type()
		
	# Compute
	path_cells = _compute_path_cells()
	extra_path = _get_path(null, {C: extra_path_connections, M:1})
	
func _get_path_cells():
	return path_cells
	
func _get_extra_path():
	return extra_path
	
func _compute_path_cells():
	var path_cells = []
	var y = 0
	for index in range(MAP_SIZE.x * MAP_SIZE.y):
		
		var x = int(index) % int(MAP_SIZE.x ) 
		if index > 0 and x == 0: y+=1
		
		var path_tile = _get_path(Vector2(x, y), _map_data[index])
		path_cells.append(path_tile)
	
	return path_cells

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
	if content.has(M):
		# FOR DEFAULT MAP
		path_tile.setup(index, connections, bool(content[M]))
	elif content.has(str(M)):
		# FOR JSON LOAD MAP
		path_tile.setup(index, connections, bool(content[str(M)]))
	else:
		print("ERR: Moveable flag not set")
		
	
	return path_tile

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
		for i in range(PATH_DISTRIBUTION[type]):
			paths.append(type)
	
	_available_paths  = _shuffleList(paths)

func _shuffleList(list):
    var shuffled_list = [] 
    var index_list = range(list.size())
    for i in range(list.size()):
        var x = randi()%index_list.size()
        shuffled_list.append(list[index_list[x]])
        index_list.remove(x)
    return shuffled_list