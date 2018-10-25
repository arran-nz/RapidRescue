# Collectables - Manages logic pertaining to the spawning of collectables and types.

extends Node

enum TYPES { Firewall, Smartphone, Router, USB, ManInMiddle, Malware, ROOT}

const STAGES = [
				[Smartphone, USB],
				[Firewall, ManInMiddle, Router],
				[Malware],
				[ROOT]
	]
	
var _current_stage

func _init():
	_current_stage = 0
	var collectable_t = _get_collectable_type()
	pass
	
	
	
func _get_collectable_type():
	var v = rand_range(0, STAGES[_current_stage].size())
	return STAGES[_current_stage][v]
