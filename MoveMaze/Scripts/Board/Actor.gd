# Actor - Move under the indirect control of AI or Human command.

extends Spatial

const _TRAVEL_TIME = 1.0
const _ROTATION_PROGRESS = 0.4

const ACTOR_TEXTURE = {
	0 : preload('res://Materials/boat/player1.tres'),
	1 : preload('res://Materials/boat/player2.tres'),
	2 : preload('res://Materials/boat/player3.tres')
}
const PRIMARY_TEX_ALTAS = [0, 2]

# Path which this actor moves WITH when not traversing
var active_path
# Unique ID
var id

var _remaining_seats
const COLLECTABLE_SCALE = Vector3(0.5,0.5,0.5)

var _route
var _start_pos
var _start_angle
var _target_angle
var _t


var traversing setget ,_has_route

var obj_collectable = preload("res://Objects/3D/Collectable.tscn")
var _total_seats
var _start_passengers
var passenger_count setget ,_get_passenger_count

signal collected_item
signal final_target_reached

func setup(id, active_path, start_passengers=0):
	self.id = int(id)
	self.active_path = active_path
	self._start_passengers = start_passengers

func get_repr():
	return {
		'id' : id,
		'people' : self.passenger_count,
		'index_x' : active_path.index.x,
		'index_y' : active_path.index.y
	}

func _get_passenger_count():
	return _total_seats - _remaining_seats.size()

func _ready():
	_t = 0
	_assign_model_tex()
	_orient_start_rotation()
		
	_remaining_seats = _get_seats()
	_total_seats = _remaining_seats.size()
	
	for i in _start_passengers:
		var item = obj_collectable.instance()
		_rescue_collectable(item)
		

func _assign_model_tex():
	for i in PRIMARY_TEX_ALTAS:
		$MeshInstance.set_surface_material(i, ACTOR_TEXTURE[id])

func _orient_start_rotation():
	# Find the first connection and rotate facing that direction.
	for c in active_path.connections:
		if active_path.connections[c]:
			match c:
				'N':
					rotation_degrees.y = 180;
				'E':
					rotation_degrees.y = 90;
				'S':
					rotation_degrees.y = 0;
				'W':
					rotation_degrees.y = 270;
			break

func set_route(route):
	self._route = route
	#Bind to end path of route
	active_path = _route.back()
	_reset_moving_values()

func _process(delta):
	
	_t += delta
	
	if _has_route():
		_rotate_toward_target()
		_move_toward_target()
	else:
		_check_for_collectable()
		translation = active_path.traversal_pos

func _rotate_toward_target():
	
	var progress = _t / _TRAVEL_TIME
	if progress <= _ROTATION_PROGRESS:
		rotation.y = lerp(_start_angle, _target_angle, progress / _ROTATION_PROGRESS)
	else:
		rotation.y = _target_angle

func _move_toward_target():
	
	if _t >= _TRAVEL_TIME:
		translation = _route.front().traversal_pos
		_route.pop_front()
		_reset_moving_values()
		return
	
	var progress = _t / _TRAVEL_TIME
	
	var vector_difference = _route.front().traversal_pos - _start_pos
	var next_pos = _start_pos + (progress * vector_difference)

	translation = next_pos
	
func _reset_moving_values():
	_t = 0
	_start_pos = translation
	if _has_route():
		var vector_difference = (_route.front().traversal_pos - _start_pos).normalized()
		_target_angle = atan2(vector_difference.x, vector_difference.z)
		_start_angle = rotation.y
	else:
		emit_signal('final_target_reached')

func _has_route():
	return _route != null && len(_route) > 0

# Region: Collectable

func _check_for_collectable():
	if active_path.has_collectable: 
		if _has_seat():
			var item = active_path.pickup_collectable()
			_rescue_collectable(item)
		else:
			print('No more room!')

func _has_seat():
	return _remaining_seats != null && _remaining_seats.size() > 0

func _rescue_collectable(item):
	add_child(item)
	item.set_process(false)
	item.scale = COLLECTABLE_SCALE
	item.translation = _remaining_seats.pop_front()

	emit_signal("collected_item", item)
	
func _get_seats():
	var seats = []
	for c in get_children():
		if c.name.find('Seat') != -1:
			seats.append(c.translation)
	return seats