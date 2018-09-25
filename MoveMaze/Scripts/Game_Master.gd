# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var board_obj = get_parent().get_node('Board')
onready var hand_obj = get_parent().get_node('Hand')

var human_players = 4
var ai_players = 0

var turn_manager

func _ready():
	
	board_obj.connect('extra_path_ready', self, 'setup_hand')
	board_obj.connect('board_ready', self, 'board_ready')

func board_ready():
	"""Called when the board has signaled."""
	print("Board Ready")
	
	#Setup board input
	var board_extent = board_obj.board_size * board_obj.tile_size
	var board_input = board_obj.get_child(0)
	board_input.resize_collider(board_extent)
	board_input.connect('board_interaction', self, 'board_interaction')
	
	board_obj.spawn_actors(human_players)
	
	
	var players = []
	for i in range(human_players):
		var player = Player.new(i, "Player %s" % (i + 1))
		players.append(player)
		
	turn_manager = TurnManager.new(players)

func board_interaction(event):
	
	var success = board_obj.request_actor_movement(event.position, turn_manager.current_player.index)
	if success:
		turn_manager.cycle()

func setup_hand(inject_ref, extra_path):
	hand_obj.setup(inject_ref, extra_path)
	
	for inj in board_obj.injectors:
		inj.connect('injector_pressed', hand_obj, 'move_path_to_injector')
		

class TurnManager:
	var current_player
	
	var _players = []
	var _player_count
	
	func _init(players):
		self._players = players
		self._player_count = len(players)
		# Choose random starting player
		current_player = players[randi() % _player_count]		
	
	func cycle():
		if current_player.index + 1 < _player_count:
			current_player = _players[current_player.index + 1]
		else:
			current_player = _players[0]

class Player:
	var index
	var display_name
	
	func _init(index, display_name):
		self.index = index
		self.display_name = display_name