extends Area2D

var hot

signal click_action

var inj_direction
var inj_board_index

func init(inj_board_index, inj_direction):
	self.inj_board_index = inj_board_index
	self.inj_direction = inj_direction
	pass

func _input_event(viewport, event, shape_idx):
	if event.is_pressed() and !hot:
		emit_signal("click_action", inj_board_index, inj_direction)
		
	pass