# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var board_obj = get_parent().get_node('Board')
onready var hand_obj = get_parent().get_node('Hand')

var human_players = 2
var ai_players = 0

var players = []
var current_player

func _ready():
	
	board_obj.connect('extra_path_ready', self, 'setup_hand')
	board_obj.connect('board_ready', self, 'board_ready')

func board_ready():
	"""Called when the board has signaled."""
	print("Board Ready")
	
	board_obj.spawn_actors(human_players)
	
	for i in range(human_players):
		var player = Player.new(i, "Player %s" % (i + 1))
		players.append(player)

	# Choose random starting player
	current_player = players[randi() % human_players]	
	print("Starting player is %s" % current_player.display_name)

func setup_hand(inject_ref, extra_path):
	hand_obj.setup(inject_ref, extra_path)
	
	for inj in board_obj.injectors:
		inj.connect('injector_pressed', hand_obj, 'move_path_to_injector')
		
func _get_next_player():
	if current_player.actor_index + 1 < human_players:
		current_player = players[current_player.actor_index + 1]
	else:
		current_player = players[0]

class Player:
	var actor_index
	var display_name

	func _init(actor_index, display_name):
		self.actor_index = actor_index
		self.display_name = display_name