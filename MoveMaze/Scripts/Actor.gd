extends Node2D

var active_path

var _route
var _r_index

var _start_pos
var _t

# Travel time in seconds
const _TRAVEL_TIME = 0.4
# Target Threshold in Pixels
const _TARGET_THRESHOLD = 2


func _ready():
	_start_pos = position
	pass
	
func _process(delta):
	
	if _route != null:
		_move_toward_target(delta)
	else:
		position = active_path.position
		
func _move_toward_target(delta):
	var target_position = _route[_r_index].position
	
	# If finished traversing the route
	if position == _route[len(_route)-1].position:
		active_path = _route[_r_index]
		_route = null	
	# If reached target
	elif position == target_position:
		_r_index += 1
		
	# Calculte travel distance
	_t += delta / _TRAVEL_TIME
	var next_pos = _start_pos.linear_interpolate(target_position, _t)
	
	# If 'Close Enough' to target, move there
	if (target_position - position).length() <= _TARGET_THRESHOLD:
		position = target_position
		_start_pos = position
		_t = 0
	# Otherwise keep moving
	else:
		position = next_pos

func set_route(route):
	self._route = route
	_start_pos = position
	_t = 0
	_r_index = 1
