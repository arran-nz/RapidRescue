# Board_Input - Manage mouse interaction on the board.

extends Area2D

signal board_interaction

func resize_collider(extent):
	print(extent)
	var collider = get_child(0)
	collider.shape.extents = extent / 2
	collider.position = extent / 2	


func _input_event(viewport, event, shape_idx):
	if event.is_pressed():
		emit_signal("board_interaction", event)
	pass