# Path - An object which is used to direct `ACTORS` across the board and store `ITEMS`.

extends Spatial

var connections
var moveable
var collectable
# Index Relative to the playing board
var index

var traversal = TraversalInfo.new()
var has_collectable setget ,_has_collectable


signal pressed

const MESH_MAP = {
	# Straight
	'S': preload('res://Objects/3D/Path_Meshs/Straight.tscn'),
	# Corner
	'C': preload('res://Objects/3D/Path_Meshs/Corner.tscn'),
	# T-Intersection
	'T': preload('res://Objects/3D/Path_Meshs/Intersection.tscn'),
	# Three Pillars
	'P': preload('res://Objects/3D/Path_Meshs/River/Home_Dock.tscn'),

	# STALE_FLOOR to hint non-moveable paths
	'STALE_FLOOR':preload('res://Objects/3D/Path_Meshs/River/RiverBed_Seaweed.tscn')
}

const INIT_ROTATION_MAP = {
	# Straight
	'NS' : 90,
	'EW' : 0,
	# Corner
	'ES' : 90,
	'NE' : 180,
	'NW' : 270,
	'SW' : 0,
	# T Intersection
	'ESW' : 0,
	'NES' : 90,
	'NEW' : 180,
	'NSW' : 270,
}

var mesh_instance

var easing = preload('res://Scripts/Easing.gd')
var move_easer = easing.Helper.new(0.4, funcref(easing,'smooth_stop5'))
var rot_easer = easing.Helper.new(0.4, funcref(easing,'smooth_stop5'))

# Custom position for Actor traversal.
var traversal_pos setget ,get_traversal_pos

const PD = preload('res://Scripts/Board/Definitions.gd').PathData

signal target_reached

func setup(index, connections, moveable, collectable=null):
	self.index = index
	self.connections = connections
	self.moveable = moveable
	self.collectable = collectable

func _ready():
	_set_model_and_rotation()
	if collectable:
		add_child(collectable)

func get_traversal_pos():
	var tp = translation
	tp.y += 0.25
	return tp

func get_repr():
	"""Return path connections string representation."""
	if _has_collectable():
		return {
			PD.INDEX : index,
			PD.CONNECTIONS : _get_connection_str(),
			PD.MOVEABLE : int(moveable),
			PD.COLLECTABLE : collectable.get_repr()
		}
	else:
		return {
			PD.INDEX : index,
			PD.CONNECTIONS : _get_connection_str(),
			PD.MOVEABLE : int(moveable),
		}

func _get_connection_str():
	var con_str = ''
	for c in connections:
		if connections[c]:
			con_str += c
	return con_str

func set_as_dock():
	if mesh_instance:
		remove_child(mesh_instance)
	mesh_instance = MESH_MAP['P'].instance()
	add_child(mesh_instance)

func _set_model_and_rotation():
	# Update model based on connections
	var connection_string = _get_connection_str()
	# Set the Initial rotation of this node based on the connection string.
	rotation_degrees.y = INIT_ROTATION_MAP[connection_string]

	match connection_string:
		# Straight
		'NS', 'EW':
			mesh_instance = MESH_MAP['S'].instance()
		# Corner
		'ES', 'NE', 'NW', 'SW':
			mesh_instance = MESH_MAP['C'].instance()
		# T-Intersection
		'ESW', 'NES', 'NEW', 'NSW':
			mesh_instance = MESH_MAP['T'].instance()

	add_child(mesh_instance)

	if not moveable:
		mesh_instance.get_child(0).get_child(0).mesh = MESH_MAP['STALE_FLOOR'].instance().mesh

func update_index(index):
	self.index = index

func _process(delta):
	if move_easer.is_valid():
		_move_toward_target(delta)

	if rot_easer.is_valid():
		_rotate_toward_angle(delta)

# Region: Movement

func _move_toward_target(delta):

	move_easer.process(delta)

	if  move_easer.progress >= 1 or translation == move_easer.target:
		translation = move_easer.target
		move_easer.reset()
		move_easer.enabled = false
		emit_signal("target_reached")
		return

	var difference = move_easer.target - move_easer.start
	var next_pos = move_easer.start + (move_easer.progress * difference)

	translation = next_pos

func set_target(target, is_instant=false):

	if is_instant:
		translation = target
		move_easer.start = translation
		move_easer.target = translation
		move_easer.enabled = false
	else:
		move_easer.start = translation
		move_easer.target = target
		move_easer.enabled = true
		move_easer.reset()

# Region: Rotation

func _rotate_toward_angle(delta):

	rot_easer.process(delta)

	if rot_easer.progress >= 1:
		rotation_degrees.y = rot_easer.target
		rot_easer.reset()
		rot_easer.enabled = false
		return

	var difference = rot_easer.target - rot_easer.start
	var next_rot = rot_easer.start + (rot_easer.progress * difference)
	rotation_degrees.y = next_rot

func rotate_90():
	var names = connections.keys()
	var values = connections.values()
	var temp_values = values.duplicate()

	#Shift Bool
	var count = connections.size()
	for i in count:
		if i-1 >= 0:
			values[i] = temp_values[i - 1]
		else:
			values[i] = temp_values[count - 1]

	# Apply Rotation to connections
	for i in len(connections):
		connections[names[i]] = values[i]

	# Set start rotation and target

	# If this a new rotation from progress zero, rotate 90 from current roations.
	if rot_easer.progress == 0:
		rot_easer.start = rotation_degrees.y
		rot_easer.target = rotation_degrees.y - 90
		rot_easer.enabled = true
	# If the progress is not 0, rotate 90 degrees from the current target and reset the easer.
	else:
		rot_easer.start = rotation_degrees.y
		rot_easer.target = rot_easer.target - 90
		rot_easer.reset()

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	# Check if index is not null, as null would indicate it's in the HAND
	if event.is_pressed() and index != null:
		press_path()

func press_path():
	emit_signal("pressed", self)

# Region: Collectable

func _has_collectable():
	return collectable != null

func pickup_collectable():
	var t = collectable
	remove_child(collectable)
	collectable = null
	return t

func store_collectable(item):
	add_child(item)
	collectable = item

class TraversalInfo:
	"""Used for traversing the board / path finding."""
	var parent
	var h_cost
	var g_cost

	func _init():
		self.g_cost = 0
		self.h_cost = 0