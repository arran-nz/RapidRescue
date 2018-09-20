# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var _input_ = get_child(0)

onready var board_obj = get_parent().get_node('Board')
onready var hand_obj = get_parent().get_node('Hand')


func _ready():
	_setup_input_signals()
	
	board_obj.connect('extra_path_ready', self, 'setup_hand')

func _setup_input_signals():
	_input_.connect('rotate_hand', hand_obj, 'rotate_path')	

func setup_hand(inject_ref, extra_path):
	hand_obj.setup(inject_ref, extra_path)
	
	for inj in board_obj.injectors:
		inj.connect('injector_pressed', hand_obj, 'inject_path')