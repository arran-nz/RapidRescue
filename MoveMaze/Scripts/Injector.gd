# Path_Injector - Store information regarding injection location and direction and handle input.

extends Spatial

var disabled setget _set_disabled
var hovered setget _set_hovered

signal pressed

# What direction the path is injected towards.
var inj_direction
# Where the path get injected.
var inj_board_index

func _set_hovered(value):
	if value:
		var tmp = $Mesh.get_surface_material(0).duplicate()
		tmp.albedo_color = Color('f58765')
		$Mesh.set_surface_material(0, tmp)
	else:
		$Mesh.get_surface_material(0).albedo_color = Color(1, 1, 1)

func _set_disabled(value):
	visible = !value
	disabled = value

func setup(inj_board_index, inj_direction):
	self.inj_board_index = inj_board_index
	self.inj_direction = inj_direction
	
func _ready():
	#orient in the injection direction.
	look_at(translation + Vector3(inj_direction.x, 0 ,inj_direction.y), Vector3(0,1,0))

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_pressed() and !disabled:
		press_injector()

func press_injector():
	emit_signal("pressed", self)