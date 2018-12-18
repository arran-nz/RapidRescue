# Input_Manager - Manage all gamepad and keyboard input events.

extends Node

signal rotate_hand
signal world_select

signal move_selector
signal select

func subscribe(signal_name, obj, method):
		self.connect(signal_name, obj, method)
		
func unsubscribe(signal_name, obj, method):
		self.disconnect(signal_name, obj, method)

func _input(event):
    # Mouse in viewport coordinates
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		emit_signal('world_select', event.position)
		
	if event.is_action_pressed('rotate_hand') : emit_signal('rotate_hand')