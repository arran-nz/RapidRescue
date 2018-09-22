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

# Travel time in seconds
const _TRAVEL_TIME = 0.4
# Target Threshold in Pixels
const _TARGET_THRESHOLD = 2

func _ready():
	_start_pos = position
	pass

func setup(index, active_path):
	self.index = index
	self.active_path = active_path
	self.position = active_path.position

func _process(delta):
	
	if _has_route():
		_move_toward_target(delta)
	else:
		position = active_path.position
		
func _move_toward_target(delta):
	
	# Calculte travel distance
	_t += delta / _TRAVEL_TIME
	var next_pos = _start_pos.linear_interpolate(_next_route_path.position, _t)

	# If 'Close Enough' to target, move there
	if (_next_route_path.position - position).length() <= _TARGET_THRESHOLD:
		position = _next_route_path.position
	# Otherwise keep moving
	else:
		position = next_pos
		
	# If reached target
	if position == _next_route_path.position:
		_set_next_target()
		_reset_moving_values()

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

