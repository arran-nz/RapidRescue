extends Spatial

const SPAWN_HEIGHT = 18

const IMPACT_TRAMA = 0.65

var easing = preload('res://Scripts/Easing.gd')
var move_easer = easing.Helper.new(3.3, funcref(easing,'smooth_start4'))

func _ready():
	translation = move_easer.start

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
		get_viewport().get_camera().add_trauma(IMPACT_TRAMA)
		return

	var difference = move_easer.target - move_easer.start
	var next_pos = move_easer.start + (move_easer.progress * difference)

	translation = next_pos

func _enter_tree():
	move_easer.start = Vector3(0, SPAWN_HEIGHT ,0)
	move_easer.target = Vector3(0,0,0)

func _exit_tree():
	# been collected
	pass

func get_repr():
	"""Return unique representation for saving object information."""
	return 1



