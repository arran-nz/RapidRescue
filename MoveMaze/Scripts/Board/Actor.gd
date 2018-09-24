# Actor - Move under the indirect control of AI or Human command.

extends Node2D

# Path which this actor moves WITH when not traversing
var active_path

var _next_route_path
var _route

var _start_pos
var _t = 0

var traversing setget ,_has_route

# Travel time in seconds
const _TRAVEL_TIME = 0.4
# Target Threshold in Pixels
const _TARGET_THRESHOLD = 2

func _ready():
	_start_pos = position
	pass
	
func _process(delta):
	
	if _has_route():
		_move_toward_target(delta)

		# If reached target
		if position == _next_route_path.position:
			_set_next_target()
			_reset_moving_values()
	else:
		position = active_path.position
		
func _move_toward_target(delta):
	
	_t += delta
	var vector_difference = _next_route_path.position - _start_pos
	var next_pos =  _start_pos + vector_difference * (_t / _TRAVEL_TIME)
	
	if _t < _TRAVEL_TIME:
		position = next_pos
	else:
		position = _next_route_path.position

func _set_next_target():
	_next_route_path = _route.pop_front()
	
func _reset_moving_values():
	_t = 0
	_start_pos = self.position
	
func _has_route():
	return _next_route_path != null

func set_route(route):
	self._route = route
	active_path = _route[-1]
	_set_next_target()
	_reset_moving_values()

