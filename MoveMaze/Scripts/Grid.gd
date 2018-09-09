extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

var grid_size = Vector2(9,9)
var map_size = Vector2(7,7)
var path_cells
var injectors = []

				
var DIRECTION = {
				'N' : Vector2(0, -1),
				'E' : Vector2(1, 0),
				'S' : Vector2(0, 1),
				'W' : Vector2(-1, 0),
	}
	

# Load the class resource when calling new().
onready var obj_path = preload("res://Objects/Path.tscn")
onready var obj_injector = preload("res://Objects/Path_Injector.tscn")
var _board_gen_res = load("res://Scripts/BoardGenerator.gd")

func _ready():
	var _board_generator = _board_gen_res.new()	
	path_cells = _board_generator.gen_board(map_size, obj_path)
	
	var tile_padding =  _calc_board_padding()
	
	_spawn_paths(tile_padding)
	_spawn_injectors(tile_padding)

func _injector_call(injector):
	if injector.push_direction == DIRECTION['S'] \
	or injector.push_direction == DIRECTION['N']:
		_move_column(injector.index, injector.push_direction)
	else:
		_move_row(injector.index, injector.push_direction)
	pass

func _spawn_injectors(tile_padding):
	pass
	
	var x_indices = []
	for x in range(map_size.x):
		if path_cells[x][0].Moveable:
			x_indices.append(x)
			
	var y_indices = []
	for y in range(map_size.y):
		if path_cells[0][y].Moveable:
			y_indices.append(y)
	
	var NW = world_to_map((path_cells[0][0].position))
	var SW = world_to_map((path_cells[0][map_size.y - 1].position))
	
	#NORTH AND SOUTH SIDES
	for x_i in x_indices:
		
		var n_index = Vector2(NW.x + x_i, NW.y + DIRECTION['N'].y)
		var temp_north_inj = obj_injector.instance()
		temp_north_inj.position = map_to_world(n_index) + half_tile_size
		
		temp_north_inj.init(DIRECTION['S'], x_i)
		injectors.append(temp_north_inj)
		add_child(temp_north_inj)
		
		var s_index = Vector2(NW.x + x_i, NW.y + (map_size.y - 1) + DIRECTION['S'].y)
		var temp_south_inj = obj_injector.instance()
		temp_south_inj.position = map_to_world(s_index) + half_tile_size
		
		temp_south_inj.init(DIRECTION['N'], x_i)
		injectors.append(temp_south_inj)
		add_child(temp_south_inj)
	
	#EAST AND WEST SIDES
	for y_i in y_indices:
		var e_index = Vector2(NW.x + (map_size.x - 1) + DIRECTION['E'].x, NW.y + y_i)
		var temp_east_inj = obj_injector.instance()
		temp_east_inj.position = map_to_world(e_index) + half_tile_size
		
		temp_east_inj.init(DIRECTION['W'], y_i)
		injectors.append(temp_east_inj)
		add_child(temp_east_inj)
		
		var w_index = Vector2(NW.x + DIRECTION['W'].x, NW.y + y_i)
		var temp_west_inj = obj_injector.instance()
		temp_west_inj.position = map_to_world(w_index) + half_tile_size

		temp_west_inj.init(DIRECTION['E'], y_i)
		injectors.append(temp_west_inj)
		add_child(temp_west_inj)
		
	for inj in injectors:
		inj.connect("click_action", self, "_injector_call")
	
		

func _spawn_paths(tile_padding):
	
	for x in range(map_size.y):
		for y in range(map_size.x):
			var px = (x * tile_size.x)
			var py = (y * tile_size.y)
			path_cells[x][y].position = Vector2(px, py) + (tile_padding * tile_size) + half_tile_size
			add_child(path_cells[x][y])
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		_move_row(1, DIRECTION['E'])
	
func _calc_board_padding():
	"""Centers the board."""
	var padding = ((grid_size - map_size) / 2) * tile_size
	
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


func _move_row(index, dir):
	for x in range(map_size.x):
		var cell = path_cells[x][index]
		if(!cell.Moveable):
			print("EXC: CANT MOVE THIS ROW")
		else:
			var target = get_next_cell_position(cell.position, dir)
			cell.set_target(target)
		
func _move_column(index, dir):
	for y in range(map_size.y):
		var cell = path_cells[index][y]
		if(!cell.Moveable):
			print("EXC: CANT MOVE THIS COLUMN")
		else:
			var target = get_next_cell_position(cell.position, dir)
			cell.set_target(target)

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