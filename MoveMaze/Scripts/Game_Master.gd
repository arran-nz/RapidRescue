# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var obj_board = preload("res://Objects/3D/GridMap.tscn")
onready var obj_tile_selector = preload('res://Objects/3D/Tile_Selector.tscn')

var res_persistent_data = preload('res://Scripts/System/Persistent_Data.gd')
var res_inj_selector = preload('res://Scripts/System/Injector_Selector.gd')
var persistent_io
var inj_selector

onready var player_indc = get_parent().get_node("Player_Indicator")

var tile_selector
var board
var hand

# Turn Mananger
var tm

func _ready():
	persistent_io = res_persistent_data.new()
	board = obj_board.instance()
	tile_selector = obj_tile_selector.instance()
	add_child(board)
	add_child(tile_selector)

func setup_from_autosave():
	if board.initialized:
		return
	var autosave = persistent_io.auto_load()
	if autosave != null:
		print("Loaded Auto")
		board.setup_from_dict(autosave)
		setup_game()
	else:
		print("No Autosave found.")
	
func setup_new_game(players=2):
	if board.initialized:
		return
	print("New Game")
	board.setup_new_game(players)
	setup_game()
	
func setup_game():
	board.connect('board_paths_updated', self, 'can_current_player_move')
	
	# Setup Injector input
	for inj in board.injectors:
		inj.connect('injector_pressed', self, 'request_path_injection')
	
	# Setup Path Input
	for path in board.path_cells:
		path.connect('path_pressed', self, 'path_select')
	board.hand.current_path.connect('path_pressed', self, 'path_select')
	
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
		
	# Tile Selector
	tile_selector = get_node('TileSelector')
	tile_selector.setup(board, false)
	
	#Injector Selector
	inj_selector = res_inj_selector.new()
	inj_selector.setup(board, true)
		
	tm = TurnManager.new(players)
	tile_selector.current_index = tm.current_player.actor.active_path.index
	
	# Update Player Indicator
	player_indc.update_indicator(tm.current_player.actor)

func auto_save():
	persistent_io.auto_save(board.get_repr())
	
func path_select(path):
	"""Called when a path has been pressed."""
	if tm.current_state == tm.WAITING_FOR_MOVEMENT:
		var success = board.request_actor_movement(path, tm.current_player.actor)
		if success:
			cycle_turn()
	else:
		print("%s must place path first!" % tm.current_player.display_name)

func request_path_injection(injector):
	"""Called when an injector has been pressed."""
	if tm.current_state == tm.WAITING_FOR_INJECTION:
		board.hand.move_path_to_injector(injector)
		tm.current_state = tm.WAITING_FOR_MOVEMENT
		tile_selector.current_index = tm.current_player.actor.active_path.index
		tile_selector.active = true
		inj_selector.active = false

	else:
		print("Already placed path, %s please move." % tm.current_player.display_name)

func can_current_player_move():
	"""Check current_player reach - if none, force a turn cycle"""
	var reach = board.request_actor_reach(tm.current_player.actor)
	if len(reach) <= 1:
		print("%s can't move, forcing cycle" % tm.current_player.display_name)
		cycle_turn()

func cycle_turn():
	auto_save()
	tm.cycle()
	
	# Update Player Indicator
	player_indc.update_indicator(tm.current_player.actor)
	
	#As Injection comes first, disable the tile_selector
	tile_selector.active = false
	inj_selector.active = true
	
func manage_collection(collected_item):
	# Update Player Indicator
	player_indc.update_indicator(tm.current_player.actor)
	board.spawn_collectable()

class TurnManager:
	var current_player
	
	var _players = []
	var _player_count
	
	enum States {
		WAITING_FOR_INJECTION,
		WAITING_FOR_MOVEMENT,
	}
	var current_state
	
	func _init(players):
		self._players = players
		self._player_count = len(players)
		# Choose random starting player
		current_player = players[randi() % _player_count]
		current_state = WAITING_FOR_INJECTION
	
	func cycle():
		if current_player.index + 1 < _player_count:
			current_player = _players[current_player.index + 1]
		else:
			current_player = _players[0]
			
		print("%s, you're up!" % current_player.display_name)
		current_state = WAITING_FOR_INJECTION

class Player:
	var index setget ,_get_index
	var display_name
	var actor
	
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