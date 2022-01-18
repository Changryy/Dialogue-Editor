extends "res://GraphEditors/NodeTemplate/GraphNode.gd"

var unloaded = true

func _ready():
	if unloaded: load_characters()

func load_characters():
	unloaded = false
	$Character.clear()
	for character in SceneHandler.editing.characters:
		$Character.add_item(character.name, character.id)
	_on_Character_item_selected()

func _on_Character_item_selected(index=0):
	var id = $Character.get_selected_id()
	var character = CharacterHandler.get_item(id)
	$Animation.clear()
	for animation in character.animations:
		$Animation.add_item(animation.name, animation.id)


func get_animation():
	var id = $Character.get_selected_id()
	var character = CharacterHandler.get_item(id)
	return character.get_animation_by_id($Animation.get_selected_id())


func select(character, animation):
	load_characters()
	if character != null and animation != null:
		$Character.select($Character.get_item_index(character))
		_on_Character_item_selected()
		$Animation.select($Animation.get_item_index(animation))
