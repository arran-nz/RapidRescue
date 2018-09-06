extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

var grid_size = Vector2(9,9)
var map_size = Vector2(7,7)
var path_cells

onready var path_t = preload("res://Path.tscn")

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


func _ready():
	_create_paths()
		

func _create_paths():
	randomize()
		
	path_cells = _create_2d_array(map_size.x, map_size.y, null)
	
	var tile_padding = ((grid_size - map_size) / 2) * tile_size
	
	var index = 0
	for y in range(map_size.y):
		for x in range(map_size.x):
			
			var temp_path = path_t.instance()
			
			_setup_path_tile(index, temp_path)
			
			var px = (x * tile_size.x) + half_tile_size.x
			var py = (y * tile_size.y) + half_tile_size.y
			temp_path.position = Vector2(px + (tile_padding.x), py + (tile_padding.y))
			add_child(temp_path)
			path_cells[x][y] = temp_path
			
			index+=1
	
func _setup_path_tile(index, path_tile):
	var is_default = true
	var content = DEFAULT_MAP[index]
	
	#If there is no default tile set, get a random path_type and a rotation

	if content == '': 
		content = _get_random_path_type('TIL')
		is_default = false
		
	var connections = {
			'N': false,
			'E': false,
			'S': false,
			'W': false
			}
			
	for c in content:
		connections[c] = true
		
	path_tile.setup(connections, is_default)

func _get_random_path_type(type_selection):
	var p_type = type_selection[rand_range(0, type_selection.length())]
	var selection = rand_range(0, PATH_TYPES[p_type].size())
	return PATH_TYPES[p_type][selection]	

func get_next_cell_position(pos, direction):
	var g_pos = world_to_map(pos)
	
	var new_grid_pos = g_pos + direction
	if(_in_grid(new_grid_pos)):
		return map_to_world(new_grid_pos) + half_tile_size
	else:	
		return map_to_world(g_pos) + half_tile_size
	
	
func _in_grid(g_pos):
	if g_pos.x < grid_size.x and g_pos.x >= 0:
		if g_pos.y < grid_size.y and g_pos.y >= 0:
			return true
	return false
	
	
func _create_2d_array(width, height, value):
    var a = []

    for x in range(width):
        a.append([])
        a[x].resize(height)

        for y in range(height):
            a[x][y] = value

    return a