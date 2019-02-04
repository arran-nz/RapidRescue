# Hand - Hold a `PATH` item to be rotated and placed onto the board.

extends Spatial

var current_path

var _inj_and_collect_ref

func setup(inject_ref, start_path):
	self._inj_and_collect_ref = inject_ref
	current_path = start_path
	current_path.set_target(translation, true)
	
	__Input__.subscribe("rotate_hand", self, "rotate_path")

func move_path_to_injector(injector):
	current_path.set_target(injector.translation)
	yield(current_path, "target_reached")
	_inject_path(injector.inj_board_index, injector.inj_direction)

func _inject_path(board_index, direction):
	if current_path != null:
		current_path = _inj_and_collect_ref.call_func(board_index, direction, current_path)
		yield(current_path, "target_reached")
		current_path.set_target(translation)

func rotate_path():
	current_path.rotate()