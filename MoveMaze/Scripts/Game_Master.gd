# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var board_obj = get_parent().get_node('Board')
onready var hand_obj = get_parent().get_node('Hand')

var human_players = 2
var ai_players = 0

# Turn Mananger
var tm

func _ready():
	
	board_obj.connect('extra_path_ready', self, 'setup_hand')
	board_obj.connect('board_ready', self, 'board_ready')

func board_ready():
	"""Called when the board has signaled."""
	print("Board Ready")
	
	#Setup Injector input
	for inj in board_obj.injectors:
		inj.connect('injector_pressed', self, 'request_path_injection')
	
	#Setup board input
	var board_extent = board_obj.board_size * board_obj.tile_size
	var board_input = board_obj.get_child(0)
	board_input.resize_collider(board_extent)
	board_input.connect('board_interaction', self, 'board_interaction')
	
	# Setup players and turn mananger
	var players = []
	for i in range(human_players):
		var player = Player.new(i, "Player %s" % (i + 1))
		players.append(player)
		
	board_obj.spawn_actors(players)
	board_obj.connect('board_paths_updated', self, 'can_current_player_move')		
		
	tm = TurnManager.new(players)

func board_interaction(event):
	"""Called when the board has been mouse pressed."""
	if tm.current_player.has_injected:
		var success = board_obj.request_actor_movement(event.position, tm.current_player.index)
		
		if success:
			tm.current_player.has_moved = true
			tm.cycle()
	else:
		print("%s must place path first!" % tm.current_player.display_name)

func request_path_injection(injector):
	"""Called when an injector has been pressed."""
	if not tm.current_player.has_injected:
		hand_obj.move_path_to_injector(injector)
		tm.current_player.has_injected = true
	else:
		print("Already placed path, %s please move." % tm.current_player.display_name)

func can_current_player_move():
	"""Check current_player reach -  if none, force a turn cycle"""
	var reach = board_obj.request_actor_reach(tm.current_player.index)
	if len(reach) <= 1:
		print("%s can't move, forcing cycle" % tm.current_player.display_name)
		tm.cycle(true)

func setup_hand(extra_path):
	"""Setup the hand with the starting path and setup injectors."""
	hand_obj.setup(funcref(board_obj, 'inject_path'), extra_path)

class TurnManager:
	var current_player
	
	var _players = []
	var _player_count
	
	func _init(players):
		self._players = players
		self._player_count = len(players)
		# Choose random starting player
		current_player = players[randi() % _player_count]
	
	func cycle(force=false):
		
		# If not a forced cycle
		# AND If the player has injected a piece and moved their actor.
		if !force \
		and !(current_player.has_injected and current_player.has_moved):
			print("ERR: Can not cycle turn, %s must inject and move OR force the cycle" % current_player.display_name)
			return
			
		if current_player.index + 1 < _player_count:
			current_player = _players[current_player.index + 1]
		else:
			current_player = _players[0]
			
		for p in _players:
			p.reset_turn()
			
		print("%s, you're up!" % current_player.display_name)

class Player:
	var index
	var display_name
	
	var has_injected
	var has_moved
	
	var collected_items = []
	
	func _init(index, display_name):
		self.index = index
		self.display_name = display_name
		
	func receive_collectable(item):
		print(display_name + ": Collected an item")
		collected_items.append(item)
		
	func reset_turn():
		has_injected = false
		has_moved = false
		