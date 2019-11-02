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

# Players
var players = []

# Scoring
# The win condition
const AMOUNT_TO_RESCUE = 5

func _ready():
	board = get_node("Master_Board/Board")

	path_selector = obj_path_selector.instance()

	board.add_child(path_selector)

func setup_from_autosave():
	# THIS IS BROKEN
	# TODO: RE-IMPLEMENT SAVE SYSTEM
	print('Save / Load Function is not operational')
	return

	if board.initialized:
		return
	var autosave = persistent_io.auto_load()
	if autosave != null:
		print("Loaded Auto")
		board.setup_from_dict(autosave)
		setup_master()
	else:
		print("No Autosave found.")

func setup_new_game(players=4):
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
	players = []
	for i in range(board.actors.size()):
		var actor = board.actors[i]
		var d_name = "Player %s" % (i + 1)
		var player = Player.new(i, d_name, actor)
		players.append(player)

	# Connect to the Board's actor_updated Signal
	board.connect("actor_updated", self, "update_current_player_indictator")

	# Path Selector
	path_selector.setup(board)

	tm = TurnManager.new(players, path_selector, hand)
	path_selector.current_index = tm.current_player.actor.active_path.index

	update_current_player_indictator()

	# Hand's Extra path
	hand.setup(
		board,
		injector_input.injectors,
		board.get_and_spawn_extra_path()
	)
	hand.current_path.connect('pressed', self, 'path_select')

	# Scoring
	board.connect('passenger_returned', self, 'reward_score')

func auto_save():
	var data = board.get_repr()
	data['hand'] = hand.get_repr()
	persistent_io.auto_save(data)

func path_select(path):
	"""Called when a path has been pressed."""
	var actor_signal = 'final_target_reached'
	var signalled_method = 'disconnect_and_cycle_turn'

	if tm.current_player.actor.is_connected(actor_signal, self, signalled_method):
		print("Actor is in route, wait!")
		return

	if tm.current_state == tm.STATES.WAITING_FOR_MOVEMENT:
		if tm.current_player.actor.active_path == path:
			cycle_turn()
			path_selector.disable_input()
		else:
			var success = board.request_actor_movement(path, tm.current_player.actor)
			if success:
					tm.current_player.actor.connect(actor_signal, self, signalled_method)
	else:
		print("%s must place path first!" % tm.current_player.display_name)

func request_path_injection(injector):
	"""Called when an injector has been pressed."""
	if tm.current_state == tm.STATES.WAITING_FOR_INJECTION:
		hand.inject_current_path(injector)
		hand.disable_input()
		tm.current_state = tm.STATES.WAITING_FOR_MOVEMENT
		path_selector.current_index = tm.current_player.actor.active_path.index

	else:
		print("Already placed path, %s please move." % tm.current_player.display_name)

func disconnect_and_cycle_turn(actor):
	actor.disconnect("final_target_reached", self, "disconnect_and_cycle_turn")
	cycle_turn()

func reward_score(actor_id):
	var current_player = players[actor_id]
	current_player.collect_point()
	print(current_player.display_name + " Rescued a peep")
	if current_player.score >= AMOUNT_TO_RESCUE:
		print(current_player.display_name + ' won the game!')

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

func update_current_player_indictator():
	player_indc.update_indicator(tm.current_player.actor)

class TurnManager:
	var current_player

	var _players = []
	var _player_count

	var path_selector
	var hand

	enum STATES {
		WAITING_FOR_INJECTION,
		WAITING_FOR_MOVEMENT,
	}
	var current_state setget set_current_state

	const OPTIONS = preload('res://Scripts/Board/Definitions.gd').Options

	func set_current_state(new_state):
		if OPTIONS.DISABLE_INJECTION:
			new_state = STATES.WAITING_FOR_MOVEMENT

		match new_state:
			STATES.WAITING_FOR_INJECTION:
				path_selector.disable_input()
				hand.enable_input()
			STATES.WAITING_FOR_MOVEMENT:
				path_selector.enable_input()
				hand.disable_input()

		current_state = new_state

	func _init(players, path_selector, hand):
		self._players = players
		self._player_count = len(players)
		self.path_selector = path_selector
		self.hand = hand
		# Choose random starting player
		current_player = players[randi() % _player_count]
		self.current_state = STATES.WAITING_FOR_INJECTION

	func cycle():
		if current_player.index + 1 < _player_count:
			current_player = _players[current_player.index + 1]
		else:
			current_player = _players[0]

		print("%s, you're up!" % current_player.display_name)
		self.current_state = STATES.WAITING_FOR_INJECTION

class Player:
	var index setget ,_get_index
	var display_name
	var actor

	var score = 0

	func _init(index, display_name, actor):
		self.index = index
		self.display_name = display_name
		self.actor = actor

	func _get_index():
		return index

	func collect_point():
		score += 1