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
	
func gen_path(grid_size, map_size, tile_size, grid):
	randomize()
	
	var board_padding = _calc_board_padding(grid_size, map_size, tile_size)
	var path_cells = []
		
				
	var y = 0
	for index in range(map_size.x * map_size.y):
		
		var x = int(index) % int(map_size.x ) 
		
		if index > 0 and x == 0: y+=1
		# print('{x}, {y}'.format({'x': x, 'y': y}))
		
		
		var content = DEFAULT_MAP[index]
		var path_tile = get_path_tile(Vector2(x,y), content, grid.obj_path)
				
		var px = (x * tile_size.x)
		var py = (y * tile_size.y)
		path_tile.position = Vector2(px, py) + (board_padding * tile_size) + (tile_size / 2)
		grid.add_child(path_tile)
		
		path_cells.append(path_tile)
			
	return path_cells
	
func get_path_tile(index, content, obj_path):
	var path_tile = obj_path.instance()
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
	
func _calc_board_padding(grid_size, map_size, tile_size):
	"""Centers the board."""
	var padding = ((grid_size - map_size) / 2) * tile_size
	var half_tile_size = tile_size / 2
	
	# If the padding does not align with a tile, add half a tile to fix alignment
	var xv = int(padding.x) % int(tile_size.x)
	if  xv != 0:
		padding.x += half_tile_size.x
		
	var yv = int(padding.y) % int(tile_size.y)
	if yv != 0:
		padding.y += half_tile_size.y
	
	padding /= tile_size
	
	print(padding)
	return padding
	
func _get_random_path_type(type_selection):
	var p_type = type_selection[rand_range(0, type_selection.length())]
	var selection = rand_range(0, PATH_TYPES[p_type].size())
	return PATH_TYPES[p_type][selection]	