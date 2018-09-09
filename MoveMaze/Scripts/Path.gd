extends KinematicBody2D

var connections
var moveable
var item
# Index Relative to the playing board
var index

var _target_pos

const _SPEED = 10000
# Target Threshold in Pixels
const _TARGET_THRESHOLD = 2

func _ready():
	_target_pos = position
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
	var vel = (_target_pos - position).normalized() * _SPEED * delta

	if (_target_pos - position).length() > _TARGET_THRESHOLD:
		move_and_slide(vel )
	else:
		position = _target_pos

func set_target(target, is_instant=false):
	if is_instant:
		position = target
		_target_pos = position
	else:
		_target_pos = target

func update_index(index):
	self.index = index

func collect_item():
	
	var temp_item = item
	item = null
	return temp_item
		
