extends Spatial

const SPAWN_HEIGHT = 20
var size
var easing = preload('res://Scripts/Easing.gd')
var move_easer = easing.Helper.new(3.2, funcref(easing,'smooth_start4'))

func _ready():
	translation = Vector3(0, SPAWN_HEIGHT ,0)
	move_easer.start = translation
	move_easer.target = Vector3(0,0,0)

func _process(delta):
	if move_easer.is_valid():
		_move_toward_target(delta)

func _move_toward_target(delta):

	move_easer.process(delta)

	if  move_easer.progress >= 1:
		translation = move_easer.target
		move_easer.reset()
		move_easer.enabled = false
		$Particles.emitting = true
		return

	var difference = move_easer.target - move_easer.start
	var next_pos = move_easer.start + (move_easer.progress * difference)

	translation = next_pos

func _exit_tree():
	# been collected
	pass

func collect(collector):
	#move to collector avaliabe position
	pass
	


