extends KinematicBody2D


var connections
var moveable
var item
# Index Relative to the playing board
var index

var _target_pos
var _start_pos
var _t

# Travel time in seconds
const TRAVEL_TIME = 0.6
# Target Threshold in Pixels
const _TARGET_THRESHOLD = 2

func _ready():
	_target_pos = position
	_start_pos = position
	pass
	
func init(index, connections, moveable, item=null):
	self.index = index
	self.connections = connections
	self.moveable = moveable
	self.item = item
	
func _process(delta):
	if _target_pos != position:
		_move_toward_target(delta)
		
func _move_toward_target(delta):
	#var vel = (_target_pos - position).normalized() * _SPEED * delta
	
	_t += delta / 0.6
	var next_pos = _start_pos.linear_interpolate(_target_pos, _t)

	if (_target_pos - position).length() > _TARGET_THRESHOLD:
		position = next_pos
	else:
		position = _target_pos

func set_target(target, is_instant=false):
	if is_instant:
		position = target
		_target_pos = position
	else:
		_start_pos = position
		_target_pos = target
		_t = 0

func update_index(index):
	self.index = index

func collect_item():
	
	var temp_item = item
	item = null
	return temp_item
		
