extends Spatial

var indictator

const ROTATE_SPEED = 10
const V3_ZERO = Vector3(0,0,0)
	
func update_indicator(node):
	
	for c in get_children():
		remove_child(c)
	
	var copy = node.duplicate()
	copy.translation = V3_ZERO
	copy.rotation = V3_ZERO
	_recursive_child_func(copy)
	add_child(copy)

func _process(delta):
	rotation_degrees.y += ROTATE_SPEED * delta

func _recursive_child_func(node):
	_apply_modifiers(node)
	for n in node.get_children():
		if n.get_child_count() > 0:
			_recursive_child_func(n)
		else:
			_apply_modifiers(n)
			
func _apply_modifiers(node):
	node.set_script(null)