extends Node2D

onready var grid_obj = get_parent()

func _ready():
	pass

func _draw():
	var LINE_COLOR = Color('#040504')
	var PATH_COLOR = Color('c20114')
	
	var BOARD_COLOR = Color("#0c120c")
	var LINE_WIDTH = 5

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
		
	draw_path(PATH_COLOR, 3)

	
func draw_path(color, line_width):
	
	var PATH_COLOR = color
	var PATH_WIDTH = line_width
	
	for item in grid_obj.path:
		if item.DOWN:
			draw_line(
				item.position,
				item.position + Vector2(0, grid_obj.tile_size.y / 2),
				PATH_COLOR,
				PATH_WIDTH)
		if item.UP:
			draw_line(
				item.position,
				item.position - Vector2(0, grid_obj.tile_size.y / 2),
				PATH_COLOR,
				PATH_WIDTH)
		if item.LEFT:
			draw_line(
				item.position,
				item.position - Vector2(grid_obj.tile_size.x / 2, 0),
				PATH_COLOR,
				PATH_WIDTH)
		if item.RIGHT:
			draw_line(
				item.position,
				item.position + Vector2(grid_obj.tile_size.x / 2, 0),
				PATH_COLOR,
				PATH_WIDTH)
		