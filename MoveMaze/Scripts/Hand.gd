# Hand - Hold a `PATH` item to be rotated and placed onto the board.

extends Spatial

var current_path
var selected_injector


var _injection_ref
var _injectors

var MAGNECTIC_THRESHOLD = 1.25
var PATH_HOVER_OFFSET = Vector3(0,1.5,0)

func enable_input():
	set_process_unhandled_input(true)
func disable_input():
	set_process_unhandled_input(false)

func _ready():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		move_current_path_to_cursor(event.position)

	if event is InputEventMouseButton:
		if event.pressed:
			match(event.button_index):
				BUTTON_LEFT:
					if selected_injector != null:
						selected_injector.press_injector()
				BUTTON_RIGHT:
					current_path.rotate_90()

	if event.is_pressed() and event.is_action('rotate_hand'):
		current_path.rotate_90()

func move_current_path_to_cursor(cursor_position):
	var cam = get_viewport().get_camera()
	var from = cam.project_ray_origin(cursor_position)
	# I don't know why this works, it was a lucky first guess.
	# ORTHONGONAL ONLY
	var to = from + cam.project_ray_normal(cursor_position) * from.y
	var mouse_world_pos = Vector3(to.x, 1, to.z)

	# Cancel if there are no injectors
	if len(_injectors) < 1:
		return

	# FIND CLOSEST INJECTOR
	var closest_injector = _injectors[0]
	for injector in _injectors:

		# Dont attract towards disabled injectors
		if injector.disabled:
			continue
		var current_mag = (mouse_world_pos - injector.translation).length()
		var closest_mag = (mouse_world_pos - closest_injector.translation).length()
		if current_mag < closest_mag:
			closest_injector = injector

	var mag = (mouse_world_pos - closest_injector.translation).length()

	var target_position
	if mag < MAGNECTIC_THRESHOLD:
		target_position = closest_injector.translation
		selected_injector = closest_injector
	else:
		target_position = mouse_world_pos + PATH_HOVER_OFFSET
		selected_injector = null

	current_path.set_target(target_position)

func setup(injectors, injection_ref, start_path):
	self._injection_ref = injection_ref
	self._injectors = injectors
	current_path = start_path
	current_path.set_target(translation, true)

func inject_current_path(injector):
	# Move to injection location
	current_path.set_target(injector.translation)
	yield(current_path, "target_reached")
	# Wait until target is reached then inject the path
	current_path = _injection_ref.call_func(injector.inj_board_index, injector.inj_direction, current_path)
	# Shake camera as injection occurs
	get_viewport().get_camera().add_trauma(0.5)

func get_repr():
	return current_path.get_repr()