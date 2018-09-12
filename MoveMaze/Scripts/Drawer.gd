extends Node2D


var Palletes = {

	'Vapor' :
		['#050023', '16324f' ,'#9d0a5c','#ea638c','#75d1ff']
	
}

var CURRENT_PALLETE = 'Vapor'

var LINE_WIDTH = 5
var GRID_LINE = 1
var CIRCLE_RADIUS = 7
var GRID_LINES_PER_CELL = 4

var _AA = true

onready var grid_obj = get_parent()

func _process(delta):
	update()

func _draw():

	var view = get_viewport().size	
	var grid_resolution = (view / grid_obj.board_size) * GRID_LINES_PER_CELL
	
	var base = Vector2(0,0) - grid_obj.position
	
	draw_rect(Rect2(base, view), Palletes[CURRENT_PALLETE][0],true)
	
	for x in range(1,grid_resolution.x):
		var col_pos = (x * grid_obj.tile_size.x) / GRID_LINES_PER_CELL
		var col_limit = view.y
		draw_line(Vector2(base.x + col_pos, base.y), Vector2(col_pos + base.x, col_limit), Palletes[CURRENT_PALLETE][1], GRID_LINE, _AA)
		
	for y in range(1, grid_resolution.y):
		var row_pos = (y * grid_obj.tile_size.y) / GRID_LINES_PER_CELL
		var row_limit = view.x
		draw_line(Vector2(base.x, base.y + row_pos), Vector2(row_limit, base.y + row_pos), Palletes[CURRENT_PALLETE][1], GRID_LINE, _AA)
		

	_draw_path()
	_draw_injectors()

func _draw_injectors():
	for injector in grid_obj.injectors:
		var current_color
		if(injector.hot): current_color = Palletes[CURRENT_PALLETE][1]
		else: current_color = Palletes[CURRENT_PALLETE][4]
		
		draw_circle(injector.position, CIRCLE_RADIUS, current_color)
	
func _draw_path():
	for item in grid_obj.path_cells:
			
		if item == null:
			break
		
		var current_color
		if(item.moveable): current_color = Palletes[CURRENT_PALLETE][3]
		else: current_color = Palletes[CURRENT_PALLETE][2]
			
		if item.connections['S']:
			draw_line(
				item.position,
				item.position + Vector2(0, grid_obj.tile_size.y / 2),
				current_color,
				LINE_WIDTH,
				_AA)
		if item.connections['N']:
			draw_line(
				item.position,
				item.position - Vector2(0, grid_obj.tile_size.y / 2),
				current_color,
				LINE_WIDTH,
				_AA)
		if item.connections['W']:
			draw_line(
				item.position,
				item.position - Vector2(grid_obj.tile_size.x / 2, 0),
				current_color,
				LINE_WIDTH,
				_AA)
		if item.connections['E']:
			draw_line(
				item.position,
				item.position + Vector2(grid_obj.tile_size.x / 2, 0),
				current_color,
				LINE_WIDTH,
				_AA)
		