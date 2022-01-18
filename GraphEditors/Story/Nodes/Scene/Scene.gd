extends "res://GraphEditors/NodeTemplate/GraphNode.gd"
signal change_colour(color)


export(NodePath) var colour_path
var colour_picker : ColorPickerButton
export(NodePath) var character_container
export(PackedScene) var character_source
export(NodePath) onready var description = get_node(description) as TextEdit
export(NodePath) onready var nochars = get_node(nochars) as Label

var scene
var confirm


func sort_items(a, b):
	return a.position.y >= b.position.y

func _ready():
	if colour_path: colour_picker = get_node(colour_path)
	if !scene:
		scene = SceneHandler.create_scene()
		scene.position = offset
		scene.size = rect_size
	else:
		offset = scene.position
		rect_size = scene.size
		colour(scene.colour)
		$Top/Name.text = scene.name
		for character in scene.characters:
			add_character(character)
		description.text = scene.description
		description.emit_signal("text_changed")
		update_slots()
	connect("resize_request", self, "resize")
	connect("offset_changed", self, "reposition")
	confirm.connect("action_confirmed", self, "delete")
	emit_signal("resize_request", rect_size)

func resize(new_size): scene.size = rect_size
func reposition(): scene.position = offset

func _on_Colour_color_changed(color):
	emit_signal("change_colour", color)
	colour(color)

func colour(color):
	# update preview
	colour_picker.color = color
	scene.colour = color
	# style colour
	for x in STYLES:
		var style = get("custom_styles/"+x).duplicate()
		style.border_color = color
		set("custom_styles/"+x, style)
	
	# slot colour
	for i in range(get_child_count()-1):
		set_slot(i,i==0,0,color,is_slot_enabled_right(i),0,color)
	for c in get_children():
		if c.is_in_group("slot"):
			c.modulate = color


func can_drop_data(position, data):
	return true

func drop_data(position, data):
	var new_characters = []
	for item in CharacterHandler.selection:
		new_characters += get_characters(item)
	for character in new_characters:
		if not character in scene.characters:
			scene.characters.append(character)
			add_character(character)


func get_characters(item):
	var result = []
	if !item.is_group: result.append(item)
	for member in item.get_members():
		result += get_characters(member)
	return result


func add_character(character):
	var new_character = character_source.instance()
	new_character.character = character
	new_character.connect("delete", self, "delete_character")
	new_character.connect("confirm", confirm, "confirm")
	confirm.connect("action_confirmed", new_character, "delete_confirm")
	get_node(character_container).add_child(new_character)
	nochars.hide()

func delete_character(character):
	scene.characters.erase(character)
	if len(scene.characters) == 0:
		nochars.show()



func _on_Name_text_changed(new_text):
	scene.name = new_text
func _on_Description_text_changed():
	if description is Node:
		scene.description = description.text


func _on_Scene_close_request():
	confirm.confirm(self, "Delete Scene")

func delete(node):
	if node == self:
		SceneHandler.delete_scene(scene)
		emit_signal("close_node", self)


func _on_Edit_pressed():
	SceneHandler.editing = scene
	get_tree().change_scene("res://GraphEditors/Scene/SceneEditor.tscn")


func update_slots():
	for i in range(get_child_count()):
		if i > 0: set_slot(i,false,0,scene.colour,false,0,scene.colour)
	for c in get_children():
		if c.is_in_group("slot"):
			remove_child(c)
			c.queue_free()
	var slots = []
	for action in scene.actions:
		if action.type == "change_scene":
			slots.append(action)
	slots.sort_custom(self, "sort_items")
	for item in slots:
		var label = Label.new()
		label.text = item.text
		label.modulate = scene.colour
		label.add_to_group("slot")
		add_child_below_node($Top, label)
	for i in range(get_child_count()):
		if get_child(i).is_in_group("slot"):
			set_slot(i,false,0,scene.colour,true,0,scene.colour)
	return slots




