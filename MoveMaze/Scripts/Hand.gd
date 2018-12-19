# Hand - Hold a `PATH` item to be rotated and placed onto the board.

extends Node2D

var current_path

var _inj_and_collect_ref

func setup(inject_ref, start_path):
	self._inj_and_collect_ref = inject_ref
	current_path = start_path
	current_path.set_target(self.position, true)
	
	__Input__.subscribe("rotate_hand", self, "rotate_path")

func move_path_to_injector(injector):
	current_path.set_target(injector.position, false)
	yield(current_path, "target_reached")
	_inject_path(injector.inj_board_index, injector.inj_direction)

func _inject_path(board_index, direction):
	if current_path != null:
		current_path = _inj_and_collect_ref.call_func(board_index, direction, current_path)

func rotate_path():
	current_path.rotate()