# Hand - Hold a `PATH` item to be rotated and placed onto the board.

extends Node2D

var current_path

var _inj_and_collect_ref

func setup(inject_ref, start_path):
	self._inj_and_collect_ref = inject_ref
	current_path = start_path
	current_path.set_target(self.position, true)

func inject_path(board_index, direction):
	if current_path != null:
		current_path = _inj_and_collect_ref.call_func(board_index, direction, current_path)
		current_path.set_target(self.position)

func rotate_path():
	var names = current_path.connections.keys()
	var values = current_path.connections.values()
	var temp_values = values.duplicate()
	
	#Shift Bool
	var count = len(names)
	for i in count:
		if i-1 >= 0:
			values[i] = temp_values[i - 1]
		else:
			values[i] = temp_values[count - 1]
			
	# Apply Rotation
	for i in len(current_path.connections):
		current_path.connections[names[i]] = values[i]
		