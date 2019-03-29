# Game_Master - Manage the sequence of game events and Human / AI turns.

extends Node

onready var obj_path_selector = preload('res://Objects/3D/Path_Selector.tscn')

var persistent_io = PersistentData.new()

onready var player_indc = $Player_Indicator
onready var injector_input = $Master_Board/Injectors
onready var hand = $Hand

var path_selector
var board

# Turn Mananger
var tm

func _ready():
	board = get_node("Master_Board/Board")

	path_selector = obj_path_selector.instance()

	board.add_child(path_selector)

func setup_from_autosave():
	if board.initialized:
		return
	var autosave = persistent_io.auto_load()
	if autosave != null:
		print("Loaded Auto")
		board.setup_from_dict(autosave)
		setup_master()
	else:
		print("No Autosave found.")

func setup_new_game(players=2):
	if board.initialized:
		return
	print("New Game")
	board.setup_new(players)
	setup_master()
	board.spawn_new_collectable()

func setup_master():
	board.connect('board_paths_updated', self, 'can_current_player_move')

	# Setup Injector input
	injector_input.setup(board)
	for inj in injector_input.injectors:
		inj.connect('pressed', self, 'request_path_injection')

	# Setup Path Input
	for path in board.path_cells:
		path.connect('pressed', self, 'path_select')

	# Setup players and turn mananger
	# Connect actors to send collected items to each respective player
	var players = []
	for i in range(board.actors.size()):
		var actor = board.actors[i]
		var d_name = "Player %s" % (i + 1)
		var player = Player.new(i, d_name, actor)
		players.append(player)

	# Connect to the Board's actor_updated Signal
	board.connect("actor_updated", self, "update_current_player_indictator")

	# Path Selector
	path_selector.setup(board, false)

	tm = TurnManager.new(players)
	path_selector.current_index = tm.current_player.actor.active_path.index

	update_current_player_indictator()

	# Hand's Extra path
	hand.setup(funcref(board, "inject_path") ,board.get_and_spawn_extra_path())
	hand.current_path.connect('pressed', self, 'path_select')

	injector_input.active = true

func auto_save():
	var data = board.get_repr()
	data['hand'] = hand.get_repr()
	persistent_io.auto_save(data)

func path_select(path):
	"""Called when a path has been pressed."""
	if tm.current_state == tm.STATES.WAITING_FOR_MOVEMENT:
		var success = board.request_actor_movement(path, tm.current_player.actor)
		if success:
			tm.current_player.actor.connect("final_target_reached", self, "disconnect_and_cycle_turn")
			path_selector.active = false
	else:
		print("%s must place path first!" % tm.current_player.display_name)

func request_path_injection(injector):
	"""Called when an injector has been pressed."""
	if tm.current_state == tm.STATES.WAITING_FOR_INJECTION:
		hand.inject_current_path(injector)
		tm.current_state = tm.STATES.WAITING_FOR_MOVEMENT
		path_selector.current_index = tm.current_player.actor.active_path.index
		path_selector.active = true
		injector_input.active = false

	else:
		print("Already placed path, %s please move." % tm.current_player.display_name)

func disconnect_and_cycle_turn(actor):
	actor.disconnect("final_target_reached", self, "disconnect_and_cycle_turn")
	cycle_turn()

func can_current_player_move():
	"""Check current_player reach - if none, force a turn cycle"""
	var reach = board.request_actor_reach(tm.current_player.actor)
	if len(reach) <= 1:
		print("%s can't move, forcing cycle" % tm.current_player.display_name)
		cycle_turn()

func cycle_turn():
	auto_save()
	tm.cycle()

	update_current_player_indictator()

	#As Injection comes first, disable the path_selector
	path_selector.active = false
	injector_input.active = true

func update_current_player_indictator():
	player_indc.update_indicator(tm.current_player.actor)

class TurnManager:
	var current_player

	var _players = []
	var _player_count

	enum STATES {
		WAITING_FOR_INJECTION,
		WAITING_FOR_MOVEMENT,
	}
	var current_state

	func _init(players):
		self._players = players
		self._player_count = len(players)
		# Choose random starting player
		current_player = players[randi() % _player_count]
		current_state = STATES.WAITING_FOR_INJECTION

	func cycle():
		if current_player.index + 1 < _player_count:
			current_player = _players[current_player.index + 1]
		else:
			current_player = _players[0]

		print("%s, you're up!" % current_player.display_name)
		current_state = STATES.WAITING_FOR_INJECTION

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