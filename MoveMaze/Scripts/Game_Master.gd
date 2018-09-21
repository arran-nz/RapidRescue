# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var board_obj = get_parent().get_node('Board')
onready var hand_obj = get_parent().get_node('Hand')


func _ready():
	
	board_obj.connect('extra_path_ready', self, 'setup_hand')

func setup_hand(inject_ref, extra_path):
	hand_obj.setup(inject_ref, extra_path)
	
	for inj in board_obj.injectors:
		inj.connect('injector_pressed', hand_obj, 'inject_path')