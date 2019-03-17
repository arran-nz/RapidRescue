# Hand - Hold a `PATH` item to be rotated and placed onto the board.

extends Spatial

var current_path

var _inject_ref

func _unhandled_input(event):
	if event.is_pressed():
		if event.is_action('rotate_hand') : current_path.rotate_90()

func setup(inject_ref, start_path):
	self._inject_ref = inject_ref
	current_path = start_path
	current_path.set_target(translation, true)

func inject_current_path(injector):
	# Move to injection location
	current_path.set_target(injector.translation)
	yield(current_path, "target_reached")
	# Wait until target is reached then inject the path
	var ejected = _inject_ref.call_func(injector.inj_board_index, injector.inj_direction, current_path)
	# Shake camera as injection occurs
	get_viewport().get_camera().add_trauma(0.2)
	# Collect the ejected path
	collect_path(ejected)

func collect_path(path):
	current_path = path
	current_path.set_target(translation)
	
func get_repr():
	return current_path.get_repr()