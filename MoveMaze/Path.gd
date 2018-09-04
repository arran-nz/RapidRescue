extends Node2D


var UP
var DOWN
var LEFT
var RIGHT

func _ready():
	pass
	
func setup(up, right, down, left):
	self.UP = up
	self.RIGHT = right
	self.DOWN = down
	self.LEFT = left

