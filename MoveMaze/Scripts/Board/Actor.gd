# Actor - Move under the indirect control of AI or Human command.

extends Spatial

const _TRAVEL_TIME = 1.0
const ACTOR_TEXTURE = {
	0 : preload('res://Materials/green.tres'),
	1 : preload('res://Materials/red.tres')
}
# Path which this actor moves WITH when not traversing
var active_path
# Unique index
var index

var _seat_positions
const COLLECTABLE_SCALE = Vector3(0.5,0.5,0.5)

var _route
var _start_pos
var _target_angle
var _t

var traversing setget ,_has_route

signal collected_item

func setup(index, active_path):
	self.index = index
	self.active_path = active_path
	translation = active_path.translation
	$MeshInstance.set_surface_material(0, ACTOR_TEXTURE[index])
	_assign_seats()

func set_route(route):
	self._route = route
	#Bind to end path of route
	active_path = _route[-1]
	_reset_moving_values()

func _process(delta):
	
	if _has_route():
		_move_toward_target(delta)

	else:
		_check_for_collectable()
		translation = active_path.translation

func _move_toward_target(delta):
	
	_t += delta
	
	if _t >= _TRAVEL_TIME:
		translation = _route.front().translation
		_route.pop_front()
		_reset_moving_values()
		return
	
	var progress = _t / _TRAVEL_TIME
	
	var vector_difference = _route.front().translation - _start_pos
	var next_pos = _start_pos + (progress * vector_difference)
	
	rotation.y = lerp(rotation.y, _target_angle, progress)

	translation = next_pos
	
func _reset_moving_values():
	_t = 0
	_start_pos = translation
	if _has_route():
		var vector_difference = (_route.front().translation - _start_pos).normalized()
		_target_angle = atan2(vector_difference.x, vector_difference.z)

func _has_route():
	return _route != null && len(_route) > 0

# Region: Collectable

func _check_for_collectable():
	if active_path.has_collectable: 
		if _has_seat():
			_rescue_collectable()
		else:
			print('No more room!')

func _has_seat():
	return _seat_positions != null && _seat_positions.size() > 0

func _rescue_collectable():
	var item = active_path.pickup_collectable()
	item.scale = COLLECTABLE_SCALE
	item.translation = _seat_positions.pop_front()
	
	add_child(item)
	emit_signal("collected_item", item)
	
func _assign_seats():
	_seat_positions = []
	for c in get_children():
		if c.name.find('Seat') != -1:
			_seat_positions.append(c.translation)
	
	