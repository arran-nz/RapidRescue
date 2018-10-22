# Collectables - Manages logic pertaining to the spawning of collectables and types.

extends Node

enum TYPES { Firewall, Smartphone, Router, USB, ManInMiddle, Malware, ROOT}

const STAGES = [
				[Smartphone, USB],
				[Firewall, ManInMiddle, Router],
				[Malware],
				[ROOT]
	]

func _init():
	pass
	
