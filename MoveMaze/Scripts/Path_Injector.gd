extends Area2D

var hot

signal click_action


var push_direction
var index

func init(push_direction, index):
	self.push_direction = push_direction
	self.index = index
	pass

func _input_event(viewport, event, shape_idx):
	if event.is_pressed():
		emit_signal("click_action", self)
		
	pass