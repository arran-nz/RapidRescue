# Input_Manager - Manage all gamepad and keyboard input events.

extends Node

signal rotate_hand

signal up
signal down
signal left
signal right

signal select

func subscribe(signal_name, obj, method):
		self.connect(signal_name, obj, method)
		
func unsubscribe(signal_name, obj, method):
		self.disconnect(signal_name, obj, method)

func _unhandled_input(event):
	if event.is_pressed():
		if event.is_action('ui_accept') : emit_signal('select')
		if event.is_action('ui_up') : emit_signal('up')
		if event.is_action('ui_down') : emit_signal('down')
		if event.is_action('ui_left') : emit_signal('left')
		if event.is_action('ui_right') : emit_signal('right')
		
	if event.is_action_pressed('rotate_hand') : emit_signal('rotate_hand')
	