extends Area2D

var hot

signal click_action


var inj_direction
var index

func init(inj_direction, index):
	self.inj_direction = inj_direction
	self.index = index
	pass

func _input_event(viewport, event, shape_idx):
	if event.is_pressed() and !hot:
		emit_signal("click_action", self)
		
	pass