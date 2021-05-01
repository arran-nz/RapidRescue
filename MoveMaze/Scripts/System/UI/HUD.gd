extends Node

var label : RichTextLabel

func _ready():
	label = $Panel/RichTextLabel

func display_message(message):
	var existing_content = label.text
	var new_message = "\n" + get_time() + "\t " + message
	label.text = new_message + existing_content

func get_time():
	var time = OS.get_time()
	return "[" + String(time.hour) +":"+String(time.minute)+":"+String(time.second) + "]"
