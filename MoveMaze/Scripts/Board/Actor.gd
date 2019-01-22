# Actor - Move under the indirect control of AI or Human command.

extends Spatial

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

const actor_colors = {
	0: Color(0.315568, 0.835938, 0.12735),
	1: Color(0.140991, 0.455284, 0.859375)
}

func _ready():
	_start_pos = translation
	pass

func setup(index, active_path):
	self.index = index
	self.active_path = active_path
	translation = active_path.translation
	$MeshInstance.get_surface_material(0).albedo_color = actor_colors[index]

func set_route(route):
	self._route = route
	# Force a float, as if it's an INT the result will be INT too.
	_time_to_node = 0.6#float(_TRAVEL_TIME) / len(_route)
	#Bind to end path of route
	active_path = _route[-1]
	_set_next_target()
	_reset_moving_values()

func _process(delta):
	
	if _has_route():
		
		_move_toward_target(delta)

	else:
		_check_and_collect_path_item()
		translation = active_path.translation
		
func _move_toward_target(delta):
	
	_t += delta
	
	if _t >= _time_to_node:
		translation = _next_route_path.translation
		_set_next_target()
		_reset_moving_values()
		return
	
	var time = _t / _time_to_node
	var per_node_progress = time
	
	var vector_difference = _next_route_path.translation - _start_pos
	var next_pos = _start_pos + (per_node_progress * vector_difference)
	
	translation = next_pos

func _check_and_collect_path_item():
	if active_path.c_storage.is_occupied:
		var item = active_path.c_storage.collect()
		emit_signal("collected_item", item)

func _set_next_target():
	_next_route_path = _route.pop_front()	
	
func _reset_moving_values():
	_t = 0
	_start_pos = translation

func _has_route():
	return _next_route_path != null