extends Node2D


var Palletes = {

	'Default' : 
	[
	'#e63946',
	'#f1faee',
	'#a8dadc',
	'#457b9d',
	'#1d3557'
	],
	
	'Alt' : 
	[
	'#d8e2dc',
	'#ffffff',
	'#ffcad4',
	'#f4acb7',
	'#9d8189'
	]
}

var CURRENT_PALLETE = 'Alt'

var LINE_WIDTH = 4
var GRID_LINE = 1
var CIRCLE_RADIUS = 10

var _AA = true

onready var grid_obj = get_parent()

func _process(delta):
	update()

func _draw():

	draw_rect(
		Rect2(
			Vector2(0,0),
			Vector2(grid_obj.grid_size.x * grid_obj.tile_size.x,
				grid_obj.grid_size.y * grid_obj.tile_size.y)
				),
		Palletes[CURRENT_PALLETE][4],
		true)
	

	for x in range(grid_obj.grid_size.x + 1):
		var col_pos = x * grid_obj.tile_size.x
		var limit = grid_obj.grid_size.y * grid_obj.tile_size.y
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, limit), Palletes[CURRENT_PALLETE][4], GRID_LINE, _AA)
		
	for y in range(grid_obj.grid_size.y + 1):
		var row_pos = y * grid_obj.tile_size.y
		var limit = grid_obj.grid_size.x * grid_obj.tile_size.x
		draw_line(Vector2(0, row_pos), Vector2(limit, row_pos), Palletes[CURRENT_PALLETE][4], GRID_LINE, _AA)
		
	draw_path()
	draw_injectors()

func draw_injectors():
	for injector in grid_obj.injectors:
		var current_color
		if(injector.hot): current_color = Palletes[CURRENT_PALLETE][0]
		else: current_color = Palletes[CURRENT_PALLETE][1]
		
		draw_circle(injector.position, CIRCLE_RADIUS, current_color)
	
func draw_path():
	for x in range(grid_obj.map_size.x):
		for y in range(grid_obj.map_size.y):
			var item = grid_obj.path_cells[x][y]
			
			if item == null:
				break
			
			var current_color
			if(item.moveable): current_color = Palletes[CURRENT_PALLETE][2]
			else: current_color = Palletes[CURRENT_PALLETE][3]
				
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
		