# Path_Generator - Generate the board paths.

extends Node

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

const DEFAULT_MAP = [
				'SE', '', 'ESW', '', 'ESW', '', 'SW',
				'', '', '', '', '', '', '',
				'NES', '', 'NES', '', 'ESW', '', 'NSW',
				'', '', '', '', '', '', '',
				'NES', '', 'NEW', '', 'NSW', '', 'NWS',
				'', '', '', '', '', '', '',
				'NE', '', 'NEW', '', 'NEW', '', 'NW',
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
	
var _available_paths  = []

var obj_path = preload("res://Objects/3D/Path_Block.tscn")

func _init():
	_distribute_paths()
	
func gen_path():
	
	randomize()
	var path_cells = []

	var y = 0
	for index in range(MAP_SIZE.x * MAP_SIZE.y):
		
		var x = int(index) % int(MAP_SIZE.x ) 
		
		if index > 0 and x == 0: y+=1
		
		var path_tile
		var content = DEFAULT_MAP[index]
		if content != '':
			path_tile = _get_defined_path(Vector2(x,y), content)
		else:
			path_tile = get_moveable_path(Vector2(x,y))

		path_cells.append(path_tile)
	return path_cells

func get_moveable_path(index=null):
	var path_tile = obj_path.instance()
	
	var connections = {
			'N': false,
			'E': false,
			'S': false,
			'W': false
			}
			
	var content = _pop_distributed_path_type()
	
	for c in content:
		connections[c] = true
		
	path_tile.setup(index, connections, true)
	
	return path_tile	

func _get_defined_path(index, content):
	var path_tile = obj_path.instance()
	
	var connections = {
		'N': false,
		'E': false,
		'S': false,
		'W': false
		}
		
	for c in content:
		connections[c] = true
		
	path_tile.setup(index, connections, false)
	
	return path_tile

func _pop_distributed_path_type():
	if len(_available_paths ) > 0:
		var p_type = _available_paths.pop_back()
		var variation = rand_range(0, PATH_VARIATIONS[p_type].size())
		return PATH_VARIATIONS[p_type][variation]
	else:
		print("ERR: No more paths available.")

func _distribute_paths():
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