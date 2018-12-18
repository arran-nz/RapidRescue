# Drawer - Draw basic geometry onto the game canvas.

extends Node2D

const STYLES = {

	'Outrun':
		{
			'Background': Color(0.052102, 0.036697, 0.144531),
			'BackgroundLines': Color(0.045227, 0.176984, 0.304688),
			'BoardLines': Color(0.121338, 0.276645, 0.4375),
			
			'Static': Color(0.615686, 0.039216, 0.360784),
			'Moveable': Color(0.738281, 0.418167, 0.70327),
			
			'PathLines': Color(0.308258, 0.576711, 0.710938),
			
			'Active': Color(0.458824, 0.819608, 1),
			'ToggleGrid': true
		},
}

const ACTOR_COLORS = [
	Color(0.339874, 1, 0.128906),
	Color(0.988281, 0.046326, 0.046326),
	Color(0.152111, 0.655186, 0.957031),
	Color(0.960938, 0.90324, 0.289554),
]


const COLLECTABLE_COLOR = Color(1, 0.652344, 0.961976)

var applied_style = 'Outrun'

const LINE_WIDTH = 4
const GRID_LINE = 1
const CIRCLE_RADIUS = 7
const GRID_LINES_PER_CELL = 1
const _AA = true

onready var gm_obj = get_parent().get_node('__Game_Master__')
onready var board_obj = get_parent().get_node('Board')
onready var hand_obj = get_parent().get_node('Hand')

func _process(delta):
	update()

func _draw():

	_draw_bg()

	if STYLES[applied_style]['ToggleGrid']:
		_draw_bg_lines()

	_draw_board_edge()
	_draw_board_paths()
	_draw_injectors()
	_draw_hand()
	_draw_actors()

	_draw_current_player_indictator()

func _draw_current_player_indictator():
	if gm_obj.tm != null:
		var actor_index = gm_obj.tm.current_player.index
		var color = ACTOR_COLORS[actor_index]
		var y_pos = get_viewport().size.y
		draw_circle(get_viewport().size, CIRCLE_RADIUS * 2, color)

func _draw_actors():
	for actor in board_obj.actors:
		var current_color = ACTOR_COLORS[actor.index]
		draw_circle(actor.global_position, CIRCLE_RADIUS * 1.2, current_color)

func _draw_board_edge():

	var rect = Rect2(board_obj.global_position - board_obj.tile_size / 2, board_obj.board_size * board_obj.tile_size)
	var color = STYLES[applied_style]['BoardLines']
	var edge_width = GRID_LINE 
	_draw_border(rect, edge_width, color)

func _draw_bg_lines():
	var view = get_viewport().size
	var grid_resolution = (view / board_obj.board_size) * GRID_LINES_PER_CELL
	var relative_pos = self.position
	var color = STYLES[applied_style]['BackgroundLines']

	for x in range(1, grid_resolution.x):
		var col_pos = (x * board_obj.tile_size.x) / GRID_LINES_PER_CELL
		var col_limit = view.y
		
		draw_line(
			Vector2(relative_pos.x + col_pos, relative_pos.y), 
			Vector2(col_pos + relative_pos.x, col_limit),
			color, GRID_LINE, _AA)

	for y in range(1, grid_resolution.y):
		var row_pos = (y * board_obj.tile_size.y) / GRID_LINES_PER_CELL
		var row_limit = view.x
		
		draw_line(
			Vector2(relative_pos.x, relative_pos.y + row_pos),
			Vector2(row_limit, relative_pos.y + row_pos),
			color, GRID_LINE, _AA)

func _draw_bg():
	var view = get_viewport().size
	var relative_pos = self.position
	var color = STYLES[applied_style]['Background']
	draw_rect(Rect2(relative_pos, view), color, true)

func _draw_board_paths():
	for item in board_obj.path_cells:
		var path_color
		var border_color
		
		if(item.moveable):
			border_color = STYLES[applied_style]['BackgroundLines']
			path_color = STYLES[applied_style]['Moveable']
		else:
			border_color = STYLES[applied_style]['BoardLines']
			path_color = STYLES[applied_style]['Static']

		_draw_path_border(item, border_color)
		_draw_path_lines(item, path_color)
		
		if item.c_storage.is_occupied:
			_draw_path_collectable(item)

func _draw_hand():
	if hand_obj.current_path != null:
		_draw_path_border(hand_obj.current_path, STYLES[applied_style]['BoardLines'])
		_draw_path_lines(hand_obj.current_path, STYLES[applied_style]['PathLines'])
		if hand_obj.current_path.collectable != null:
			_draw_path_collectable(hand_obj.current_path)

func _draw_injectors():
	for injector in board_obj.injectors:
		var current_color
		if(injector.disabled):
			current_color = STYLES[applied_style]['BoardLines']
		else:
			current_color = STYLES[applied_style]['Active']

		draw_circle(injector.global_position, CIRCLE_RADIUS, current_color)

func _draw_path_collectable(item):
	draw_circle(item.global_position, CIRCLE_RADIUS * 1.2, COLLECTABLE_COLOR)

func _draw_path_border(item, color):
	var outter_size = board_obj.tile_size * 0.8
	var outter_box = Rect2(item.global_position - outter_size / 2, outter_size)
	_draw_border(outter_box, LINE_WIDTH / 2, color)

func _draw_path_lines(item, color):

	if item.properties.has('pallete_index'):
		color = STYLES[applied_style]['Active']
		
	if item.properties.has('test'):
		color = Color(0.134802, 0.894531, 0.090851)

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
	draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + rect.size, color, width, _AA)
	draw_line(rect.position + Vector2(0, rect.size.y), rect.position + rect.size, color, width, _AA)
