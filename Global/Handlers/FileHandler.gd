extends Node
signal indicate(message)


const EXPORT_VERSION = "1.0.0"


var path

func save_project():
	emit_signal("indicate", "saving")
	var file = File.new()
	if file.open(path, File.WRITE): return emit_signal("indicate", "error occured")
	file.store_var(get_save_data())
	file.close()
	emit_signal("indicate", "saved")


func load_project():
	var file = File.new()
	if file.open(path, File.READ): return
	var data = file.get_var(true)
	file.close()
	CharacterHandler.load_items(data.characters)
	CharacterHandler.item_index = data.character_index
	ClueHandler.load_items(data.clues)
	ClueHandler.item_index = data.clue_index
	SceneHandler.load_items(data.scenes)
	SceneHandler.scene_index = data.scene_index
	SceneHandler.start = data.start_id
	SceneHandler.start_position = data.start_position
	CharacterHandler.emit_signal("update")
	ClueHandler.emit_signal("update")
	emit_signal("indicate", "loaded")


func get_save_data():
	var data = {}
	data.characters = CharacterHandler.save()
	data.character_index = CharacterHandler.item_index
	data.clues = ClueHandler.save()
	data.clue_index = ClueHandler.item_index
	data.scenes = SceneHandler.save()
	data.scene_index = SceneHandler.scene_index
	data.start_id = SceneHandler.start
	data.start_position = SceneHandler.start_position
	return data


func export_json(p):
	emit_signal("indicate", "exporting")
	var data = get_save_data()
	p += "/Dialogue"
	var dir = Directory.new()
	if dir.make_dir(p): return emit_signal("indicate", "error occured")
	p += "/"
	make_json(p, "scenes", data.scenes)
	var characters = []
	for c in data.characters:
		if not c.is_group: characters.append(c)
	make_json(p, "characters", characters)
	var clues = []
	for c in data.clues:
		if not c.is_group: clues.append(c)
	make_json(p, "clues", clues)
	var file = File.new()
	if file.open(p+"info.cfg", File.WRITE): return emit_signal("indicate", "error occured")
	file.close()
	var info = ConfigFile.new()
	if info.load(p+"info.cfg"): return emit_signal("indicate", "error occured")
	info.set_value("general", "version", EXPORT_VERSION)
	info.set_value("general", "start_id", data.start_id)
	var normal = 0
	var custom = 0
	var actions = 0
	for scene in data.scenes:
		if scene.is_custom: custom += 1
		else: normal += 1
		for action in scene.actions:
			if action.type == "custom": actions += 1
	info.set_value("general", "custom_actions", actions)
	info.set_value("scenes", "total", len(data.scenes))
	info.set_value("scenes", "normal", normal)
	info.set_value("scenes", "custom", custom)
	info.set_value("characters", "total", len(data.characters))
	info.set_value("characters", "characters", len(characters))
	info.set_value("characters", "groups", len(data.characters)-len(characters))
	info.set_value("clues", "total", len(data.clues))
	info.set_value("clues", "clues", len(clues))
	info.set_value("clues", "groups", len(data.clues)-len(clues))
	info.save(p+"info.cfg")
	emit_signal("indicate", "exported")



func make_json(file_path, file_name, data):
	var file = File.new()
	if file.open(file_path+file_name+".json", File.WRITE): return emit_signal("indicate", "error occured")
	file.store_string(JSON.print(data, "\t"))
	file.close()




