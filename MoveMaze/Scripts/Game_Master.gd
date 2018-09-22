# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var board_obj = get_parent().get_node('Board')
onready var hand_obj = get_parent().get_node('Hand')

var human_players = 4
var ai_players = 0


func _ready():
	
	board_obj.connect('extra_path_ready', self, 'setup_hand')
	board_obj.connect('board_ready', self, 'board_ready')

func board_ready():
	"""Called when the board has signaled."""
	print("Board Ready")
	board_obj.spawn_actors(human_players)

func setup_hand(inject_ref, extra_path):
	hand_obj.setup(inject_ref, extra_path)
	
	for inj in board_obj.injectors:
		inj.connect('injector_pressed', hand_obj, 'move_path_to_injector')