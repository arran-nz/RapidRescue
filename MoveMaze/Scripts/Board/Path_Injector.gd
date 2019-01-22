# Path_Injector - Store information regarding injection location and direction and handle input.

extends Spatial

var disabled

signal injector_pressed

"""What direction the path is injected towards."""
var inj_direction
"""Where the path get injected."""
var inj_board_index

func init(inj_board_index, inj_direction):
	self.inj_board_index = inj_board_index
	self.inj_direction = inj_direction

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_pressed() and !disabled:
		emit_signal("injector_pressed", self)
