extends Resource

class_name PersistentData

const SAVE_LOCATION = 'user://'
const SAVE_EXT = '.dat'

const AUTO_SAVE_NAME = 'auto'

func auto_save(dict):
	save_data(dict, AUTO_SAVE_NAME)

func auto_load():
	return load_saved_data(AUTO_SAVE_NAME)

func remove_auto():
	var abs_path = SAVE_LOCATION + AUTO_SAVE_NAME + SAVE_EXT
	Directory.new().remove(abs_path)

func save_data(dict, file_name):
	var save_file = File.new()
	save_file.open(SAVE_LOCATION + file_name + SAVE_EXT, File.WRITE)
	var contents = to_json(dict)
	save_file.store_string(contents)
	save_file.close()

func load_saved_data(file_name):
	var save_file = File.new()
	var abs_path = SAVE_LOCATION + file_name + SAVE_EXT
	if not save_file.file_exists(abs_path):
		print('FILE NOT FOUND')
		return # Error! We don't have a save to load.
	save_file.open(abs_path, File.READ)
	var contents = save_file.get_as_text()
	save_file.close()
	return parse_json(contents)
