extends Node


var DEFAULT_MAP = 	[
				'SE', '', 'ESW', '', 'ESW', '', 'SW',
				'', '', '', '', '', '', '',
				'NES', '', 'NES', '', 'ESW', '', 'NSW',
				'', '', '', '', '', '', '',
				'NES', '', 'NEW', '', 'NSW', '', 'NWS',
				'', '', '', '', '', '', '',
				'NE', '', 'NEW', '', 'NEW', '', 'NW',
	]

var PATH_TYPES = { 
				'T' : ['ESW', 'NSW', 'NEW', 'NES'],
				'I' : ['NS', 'EW'],
				'L' : ['NE', 'SE', 'SW', 'NW'] 
	}
	
func gen_board(map_size, _path_ref):
	randomize()
	
	var path_cells = _create_2d_array(map_size.x, map_size.y, null)
		
	var index = 0
	for y in range(map_size.y):
		for x in range(map_size.x):
			
			var content = DEFAULT_MAP[index]
			var path_tile = _get_path_tile(Vector2(x,y), content, _path_ref)
			
			path_cells[x][y] = path_tile
			
			index+=1
			
	return path_cells

func _get_path_tile(index, content, _path_ref):
	var path_tile = _path_ref.instance()
	
	var is_moveable = false

	
	#If there is no default tile set, get a random path_type and a rotation

	if content == '': 
		content = _get_random_path_type('TIL')
		is_moveable = true
		
	var connections = {
			'N': false,
			'E': false,
			'S': false,
			'W': false
			}
			
	for c in content:
		connections[c] = true
		
	path_tile.init(index, connections, is_moveable)
	
	return path_tile
	
func _get_random_path_type(type_selection):
	var p_type = type_selection[rand_range(0, type_selection.length())]
	var selection = rand_range(0, PATH_TYPES[p_type].size())
	return PATH_TYPES[p_type][selection]	
	
func _create_2d_array(width, height, value):
    var a = []

    for x in range(width):
        a.append([])
        a[x].resize(height)

        for y in range(height):
            a[x][y] = value

    return a