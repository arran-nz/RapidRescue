# Drawer - Draw basic geometry onto the game canvas.

extends Node2D

const STYLES = {

	'Vapor' :
		[
		Color('#050023'),
		Color('16324f'),
		Color('#9d0a5c'),
		Color('#ea638c'),
		Color('#75d1ff'),
		true
		],
		
	'Alien' :
		[
		Color('272d2d'),
		Color('50514f'),
		Color('23ce6b'),
		Color('f6f8ff'),
		Color('a846a0'),
		false
		],
	
	'70s' :
		[
		Color('262322'),
		Color('63372c'),
		Color('c97d60'),
		Color('ffbcb5'),
		Color('f2e5d7'),
		false
		],
		
	'Copic' :
		[
		Color('0e1d23'),
		Color('235789'),
		Color('c1292e'),
		Color('fdfffc'),
		Color('f1d302'),
		false
		],
}

const ACTOR_COLORS = [
	Color(0.957031, 0.152111, 0.152111),
	Color(0.151656, 0.847656, 0.072977),
	Color(0.152111, 0.655186, 0.957031),
	Color(0.960938, 0.90324, 0.289554),
]

var applied_style = '70s'

const LINE_WIDTH = 5
const GRID_LINE = 1
const CIRCLE_RADIUS = 7
const GRID_LINES_PER_CELL = 2
const _AA = true

onready var board_obj = get_parent().get_node('Board')
onready var hand_obj = get_parent().get_node('Hand')

func _process(delta):
	update()

func _draw():
	
	_draw_bg()
	
	if STYLES[applied_style].back():
		_draw_bg_lines()
		
	_draw_board_edge()
	_draw_board_paths()
	_draw_injectors()
	_draw_hand()
	_draw_actors()

func _draw_actors():
	
	for actor in board_obj.actors:
		var current_color =  ACTOR_COLORS[actor.index]
		draw_circle(actor.global_position, CIRCLE_RADIUS * 1.2, current_color)

func _draw_board_edge():
	
	var rect = Rect2(board_obj.global_position, board_obj.board_size * board_obj.tile_size)
	var color = STYLES[applied_style][1]
	var edge_width = GRID_LINE * 2
	_draw_border(rect, edge_width, color)

func _draw_bg_lines():
	var view = get_viewport().size
	var grid_resolution = (view / board_obj.board_size) * GRID_LINES_PER_CELL
	var relative_pos = self.position
	
	for x in range(1,grid_resolution.x):
		var col_pos = (x * board_obj.tile_size.x) / GRID_LINES_PER_CELL
		var col_limit = view.y
		draw_line(Vector2(relative_pos.x + col_pos, relative_pos.y), Vector2(col_pos + relative_pos.x, col_limit), STYLES[applied_style][1], GRID_LINE, _AA)
		
	for y in range(1, grid_resolution.y):
		var row_pos = (y * board_obj.tile_size.y) / GRID_LINES_PER_CELL
		var row_limit = view.x
		draw_line(Vector2(relative_pos.x, relative_pos.y + row_pos), Vector2(row_limit, relative_pos.y + row_pos), STYLES[applied_style][1], GRID_LINE, _AA)

func _draw_bg():
	var view = get_viewport().size	
	var relative_pos = self.position
	# Draw Background
	draw_rect(Rect2(relative_pos, view), STYLES[applied_style][0],true)
	
func _draw_board_paths():
	for item in board_obj.path_cells:
		var path_color
		var border_color
		if(item.moveable):
			path_color = STYLES[applied_style][3]
			border_color = STYLES[applied_style][1] 
		else:
			path_color = STYLES[applied_style][2]
			border_color = path_color
			
		_draw_path_border(item, border_color)
		_draw_path_lines(item, path_color)

func _draw_hand():
	if hand_obj.current_path != null:
		_draw_path_border(hand_obj.current_path, STYLES[applied_style][1])
		_draw_path_lines(hand_obj.current_path, STYLES[applied_style][3])

func _draw_injectors():
	for injector in board_obj.injectors:
		var current_color
		if(injector.disabled): current_color = STYLES[applied_style][1]
		else: current_color = STYLES[applied_style][4]
		
		draw_circle(injector.global_position, CIRCLE_RADIUS, current_color)
	
func _draw_path_border(item, color):
	var size = board_obj.tile_size * 0.65
	var box = Rect2(item.global_position - size / 2, size)
	_draw_border(box, 2, color)
	
func _draw_path_lines(item, color):
	
	if item.properties.has('pallete_index'):
		color = STYLES[applied_style][item.properties.get('pallete_index')]

	if item.connections['S']:
		draw_line(
			item.global_position,
			item.global_position + Vector2(0, board_obj.tile_size.y / 2),
			color,
			LINE_WIDTH,
			_AA)
	if item.connections['N']:
		draw_line(
			item.global_position,
			item.global_position - Vector2(0, board_obj.tile_size.y / 2),
			color,
			LINE_WIDTH,
			_AA)
	if item.connections['W']:
		draw_line(
			item.global_position,
			item.global_position - Vector2(board_obj.tile_size.x / 2, 0),
			color,
			LINE_WIDTH,
			_AA)
	if item.connections['E']:
		draw_line(
			item.global_position,
			item.global_position + Vector2(board_obj.tile_size.x / 2, 0),
			color,
			LINE_WIDTH,
			_AA)
			
func _draw_border(rect, width, color):
	draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), color, width, _AA)
	draw_line(rect.position, rect.position + Vector2(0, rect.size.y), color, width, _AA)
	draw_line(rect.position +  Vector2(rect.size.x, 0), rect.position + rect.size, color, width, _AA)
	draw_line(rect.position + Vector2(0, rect.size.y), rect.position + rect.size, color, width, _AA)