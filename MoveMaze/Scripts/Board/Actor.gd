# Actor - Move under the indirect control of AI or Human command.

extends Node2D

# Path which this actor moves WITH when not traversing
var active_path
# Unique index
var index

var _next_route_path
var _route

var _start_pos
var _t = 0

var traversing setget ,_has_route

signal collected_item

# Travel time in seconds
const _TRAVEL_TIME = 1.1
var _time_to_node

var sprite_map

func _ready():
	_start_pos = position
	pass

func setup(index, active_path, sprite_map):
	self.index = index
	self.active_path = active_path
	self.position = active_path.position
	self.sprite_map = sprite_map
	$Sprite.texture = sprite_map['E']

func set_route(route):
	self._route = route
	# Force a float, as if it's an INT the result will be INT too.
	_time_to_node = 0.6#float(_TRAVEL_TIME) / len(_route)
	#Bind to end path of route
	active_path = _route[-1]
	_set_next_target()
	_reset_moving_values()
	_update_sprite()

func _process(delta):
	
	if _has_route():
		
		_move_toward_target(delta)

	else:
		_check_and_collect_path_item()
		position = active_path.position
		
func _move_toward_target(delta):
	
	_t += delta
	
	if _t >= _time_to_node:
		position = _next_route_path.position
		_set_next_target()
		_reset_moving_values()
		_update_sprite()
		return
	
	var time = _t / _time_to_node
	var per_node_progress = time
	
	var vector_difference = _next_route_path.position - _start_pos
	var next_pos = _start_pos + (per_node_progress * vector_difference)
	
	position = next_pos

func _check_and_collect_path_item():
	if active_path.c_storage.is_occupied:
		var item = active_path.c_storage.collect()
		emit_signal("collected_item", item)

func _set_next_target():
	_next_route_path = _route.pop_front()	
	
func _reset_moving_values():
	_t = 0
	_start_pos = self.position

func _update_sprite():
	if _next_route_path:
		var dir = ''
		var v_dir = (_next_route_path.position - _start_pos).normalized()
		var snapped = v_dir.snapped(Vector2(0.5, 0.5))
		match snapped:
			Vector2(1, -0.5):
				dir = 'N'
			Vector2(1, 0.5):
				dir = 'E'
			Vector2(-1, 0.5):
				dir = 'S'
			Vector2(-1, -0.5):
				dir = 'W'
		$Sprite.texture = self.sprite_map[dir]

func _has_route():
	return _next_route_path != null