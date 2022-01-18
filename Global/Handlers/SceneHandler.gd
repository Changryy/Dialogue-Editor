extends Node

var scenes = []
var scene_index = 0
var editing
var start
var start_position = Vector2(-290, 260)


func create_scene():
	var scene = Scene.new()
	scene.id = scene_index
	scene_index += 1
	scenes.append(scene)
	return scene

func delete_scene(scene):
	if start == scene.id: start = null
	scenes.erase(scene)
	scene.free()

func get_scene(id):
	for scene in scenes:
		if scene.id == id: return scene


func save():
	var result = []
	for scene in scenes:
		var new_scene = inst2dict(scene)
		new_scene.characters = []
		for character in scene.characters:
			new_scene.characters.append(character.id)
		result.append(new_scene)
	return result

func load_items(new_scenes):
	scenes.clear()
	for scene in new_scenes:
		scene = dict2inst(scene)
		var new_characters = []
		for id in scene.characters:
			new_characters.append(CharacterHandler.get_item(id))
		scene.characters = new_characters
		scenes.append(scene)





