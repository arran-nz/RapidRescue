extends Node2D

var LINE_COLOR = Color('#040504')
var PATH_COLOR = Color('#c20114')
var FIXED_PATH_COLOR = Color('#FFFFFF')
var BOARD_COLOR = Color("#0c120c")
var LINE_WIDTH = 2

onready var grid_obj = get_parent()

func _ready():
	pass

func _draw():

	draw_rect(
		Rect2(
			Vector2(0,0),
			Vector2(grid_obj.grid_size.x * grid_obj.tile_size.x,
				grid_obj.grid_size.y * grid_obj.tile_size.y)
				),
		BOARD_COLOR,
		true)
	

	for x in range(grid_obj.grid_size.x + 1):
		var col_pos = x * grid_obj.tile_size.x
		var limit = grid_obj.grid_size.y * grid_obj.tile_size.y
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, limit), LINE_COLOR, LINE_WIDTH)
		
	for y in range(grid_obj.grid_size.y + 1):
		var row_pos = y * grid_obj.tile_size.y
		var limit = grid_obj.grid_size.x * grid_obj.tile_size.x
		draw_line(Vector2(0, row_pos), Vector2(limit, row_pos), LINE_COLOR, LINE_WIDTH)
		
	draw_path()

	
func draw_path():
	
	for x in range(grid_obj.map_size.x):
		for y in range(grid_obj.map_size.y):
			var item = grid_obj.path_cells[x][y]
			
			var current_color
			if(item.Moveable): current_color = FIXED_PATH_COLOR
			else: current_color = PATH_COLOR
			
			if item == null:
				break
				
				
				
			if item.Connections['S']:
				draw_line(
					item.position,
					item.position + Vector2(0, grid_obj.tile_size.y / 2),
					current_color,
					LINE_WIDTH)
			if item.Connections['N']:
				draw_line(
					item.position,
					item.position - Vector2(0, grid_obj.tile_size.y / 2),
					current_color,
					LINE_WIDTH)
			if item.Connections['W']:
				draw_line(
					item.position,
					item.position - Vector2(grid_obj.tile_size.x / 2, 0),
					current_color,
					LINE_WIDTH)
			if item.Connections['E']:
				draw_line(
					item.position,
					item.position + Vector2(grid_obj.tile_size.x / 2, 0),
					current_color,
					LINE_WIDTH)
		