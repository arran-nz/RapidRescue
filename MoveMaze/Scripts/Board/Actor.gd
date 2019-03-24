# Actor - Move under the indirect control of AI or Human command.

extends Spatial

const MAX_STEERING_FORCE = 2
const MASS = 8
const MAX_SPEED = 4

const TURN_RADIUS = 0.7
const FINAL_RADIUS = 0.1

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

# Starting Path Cell Reference
var home_dock

var _remaining_seats
const COLLECTABLE_SCALE = Vector3(0.5,0.5,0.5)

var _total_seats
var _start_passengers
var passengers = []

signal final_target_reached

var velocity = Vector3()

func setup(id, active_path):
	self.id = int(id)
	self.active_path = active_path
	self.home_dock = active_path

func get_repr():
	return {
		'id' : id,
		'people' : get_passenger_count(),
		'index_x' : active_path.index.x,
		'index_y' : active_path.index.y
	}


var route
var current_node = 0

func _process(delta):
	if route != null:
		var change = follow_route()
		translation += change * delta
		rotation.y = atan2(change.x, change.z)
		$AnimationPlayer.play("drive")
	else:
		$AnimationPlayer.play("idle")
		translation = active_path.traversal_pos

# Region: Movement

func set_route(route, end_path):
	self.route = route
	current_node = 0
	#Bind to end path of route
	active_path = end_path

func follow_route():
	var target = route[current_node]
	var dist = translation.distance_to(target)
	if dist <= TURN_RADIUS:
		current_node += 1
		if current_node >= route.size():
			if dist <= FINAL_RADIUS:
				emit_signal("final_target_reached", self)
				route = null
			else:
				current_node = route.size() - 1

	return seek(target)

func seek(target):
	var displacement = (target - translation)
	var normalized_disp = displacement.normalized()
	var displacement_length = displacement.length()
	var desired_velocity = normalized_disp * MAX_SPEED

	var steering = desired_velocity - velocity

	steering = truncate(steering,MAX_STEERING_FORCE)
	steering = steering / MASS

	velocity = truncate(velocity + steering, MAX_SPEED)

	return velocity

func truncate(a:Vector3 , maxLength:float):
	# Truncates a Vector3, capping the magnitude.
	if(a.length_squared() > (maxLength * maxLength)):
		a = (a.normalized() * maxLength)
	return a

# Region: Passengers

func add_passenger(item):
	$MeshContainer.add_child(item)
	item.set_process(false)
	item.scale = COLLECTABLE_SCALE
	item.translation = get_seat_position()
	passengers.append(item)

func retreive_passengers():
	var offboarding = passengers.duplicate()
	while len(passengers) > 0:
		$MeshContainer.remove_child(passengers.pop_front())
	_assign_seats()
	return offboarding

func get_passenger_count():
	return passengers.size()

func is_at_dock():
	return active_path == home_dock

# Region: Setup

func _ready():
	_assign_model_tex()
	_orient_start_rotation()
	_assign_seats()
	_total_seats = _remaining_seats.size()

func _assign_model_tex():
	for i in PRIMARY_TEX_ALTAS:
		$MeshContainer/MeshInstance.set_surface_material(i, ACTOR_TEXTURE[id])

func _orient_start_rotation():
	# Find the first connection and rotate facing that direction.

	#Plus a random range to give a more organic feel.
	var r = rand_range(-12,12)

	for c in active_path.connections:
		if active_path.connections[c]:
			match c:
				'N':
					rotation_degrees.y = 180 + r;
				'E':
					rotation_degrees.y = 90 + r;
				'S':
					rotation_degrees.y = 0 + r;
				'W':
					rotation_degrees.y = 270 + r;
			break

# Region: Collectable Seats

func has_seat():
	return _remaining_seats != null && _remaining_seats.size() > 0

func get_seat_position():
	return _remaining_seats.pop_front()

func _assign_seats():
	var seats = []
	for c in $MeshContainer.get_children():
		if c.name.find('Seat') != -1:
			seats.append(c.translation)
	_remaining_seats = seats