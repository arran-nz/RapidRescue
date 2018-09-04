extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

var grid_size = Vector2(7,7)
var grid = []
var path = []

enum BLOCK_TYPE {EMPTY, ACTIVE, SETTLED}

onready var path_t = preload("res://Path.tscn")


func _ready():
	grid = _create_2d_array(grid_size.x, grid_size.y, EMPTY)
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var temp_path = path_t.instance()
			temp_path.setup(true,false,true,false)
			temp_path.position = Vector2((x * 64) + 32, (y * 64) + 32)
			add_child(temp_path)
			path.append(temp_path)
			


func register_path(path_obj):
	path.append(path_obj)
	

func is_cell_vacant(g_pos):
	
	
	if _in_grid(g_pos):
		var current_cell = grid[g_pos.x][g_pos.y]
		if current_cell == EMPTY:
			return true
			
	return false


func get_next_cell_position(pos, direction):
	var g_pos = world_to_map(pos)
	
	var new_grid_pos = g_pos + direction
	if is_cell_vacant(new_grid_pos):
		grid[new_grid_pos.x][new_grid_pos.y] == ACTIVE
		grid[g_pos.x][g_pos.y] = EMPTY
	
		var t_pos = map_to_world(new_grid_pos) + half_tile_size
		return t_pos
	else:
		var t_pos = map_to_world(g_pos) + half_tile_size
		return t_pos
	
	
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