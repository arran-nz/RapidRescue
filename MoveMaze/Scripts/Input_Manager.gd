# Input_Manager - Manage all gamepad and keyboard input events.

extends Node

signal rotate_hand

signal move_selector
signal select

func subscribe(signal_name, obj, method):
		self.connect(signal_name, obj, method)
		
func unsubscribe(signal_name, obj, method):
		self.disconnect(signal_name, obj, method)

func _process(delta):	
	if Input.is_action_just_pressed('rotate_hand'): emit_signal('rotate_hand')
