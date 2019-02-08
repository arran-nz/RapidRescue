# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var obj_hand = preload("res://Objects/3D/Hand.tscn")
onready var obj_board = preload("res://Objects/3D/GridMap.tscn")

onready var player_indc = get_parent().get_node("Player_Indicator")

var board
var hand

var human_players = 2
var ai_players = 0

# Turn Mananger
var tm

func _ready():
	
	setup_board()
	

func setup_board():
	"""Called when the board has signaled."""
	hand = obj_hand.instance()
	board = obj_board.instance()
	add_child(board)
	add_child(hand)
	
	board.setup()
	hand.setup(funcref(board, 'inject_path'), board.get_extra_path())
	
	# Setup Injector input
	for inj in board.injectors:
		inj.connect('injector_pressed', self, 'request_path_injection')
	
	# Setup Path Input
	for path in board.path_cells:
		path.connect('path_pressed', self, 'path_select')
	hand.current_path.connect('path_pressed', self, 'path_select')
	
	board.spawn_actors(human_players)
	board.connect('board_paths_updated', self, 'can_current_player_move')
	
	# Setup players and turn mananger
	# Connect actors to send collected items to each respective player
	var players = []
	for i in range(board.actors.size()):
		var actor = board.actors[i]
		var d_name = "Player %s" % (i + 1)
		var player = Player.new(i, d_name, actor)
		players.append(player)
		
		actor.connect("collected_item", players[i], "receive_collectable")
		actor.connect("collected_item", self, "manage_collection")
		
	tm = TurnManager.new(players)
	
	# Update Player Indicator
	player_indc.update_indicator(tm.current_player.actor)
	board.spawn_collectable()

func path_select(path):
	"""Called when a path has been pressed."""
	if tm.current_player.has_injected:
		var success = board.request_actor_movement(path, tm.current_player.actor)
		if success:
			tm.current_player.has_moved = true
			cycle_turn()
	else:
		print("%s must place path first!" % tm.current_player.display_name)

func request_path_injection(injector):
	"""Called when an injector has been pressed."""
	if not tm.current_player.has_injected:
		hand.move_path_to_injector(injector)
		tm.current_player.has_injected = true
	else:
		print("Already placed path, %s please move." % tm.current_player.display_name)

func can_current_player_move():
	"""Check current_player reach -  if none, force a turn cycle"""
	var reach = board.request_actor_reach(tm.current_player.actor)
	if len(reach) <= 1:
		print("%s can't move, forcing cycle" % tm.current_player.display_name)
		cycle_turn()

func cycle_turn():
	tm.cycle()
	# Update Player Indicator
	player_indc.update_indicator(tm.current_player.actor)
	
func manage_collection(collected_item):
	# Update Player Indicator
	player_indc.update_indicator(tm.current_player.actor)
	board.spawn_collectable()

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
			
		for p in _players:
			p.reset_turn()
			
		print("%s, you're up!" % current_player.display_name)

class Player:
	var index setget ,_get_index
	var display_name
	var actor
	
	var has_injected
	var has_moved
	
	var collected_items = 0
	
	func _init(index, display_name, actor):
		self.index = index
		self.display_name = display_name
		self.actor = actor
	
	func _get_index():
		return index
	
	func receive_collectable(item):
		print(display_name + ": Collected an item")
		collected_items += 1
		
	func reset_turn():
		has_injected = false
		has_moved = false
		