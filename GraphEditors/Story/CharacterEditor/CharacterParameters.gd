extends VBoxContainer
signal update_item(id)

export(NodePath) onready var confirm = get_node(confirm) as ConfirmationDialog
export(NodePath) onready var name_edit = get_node(name_edit) as LineEdit
export(NodePath) onready var name_label = get_node(name_label) as Label
export(NodePath) onready var colour_picker = get_node(colour_picker) as ColorPickerButton
export(NodePath) onready var description = get_node(description) as TextEdit
export(NodePath) onready var animation_container = get_node(animation_container) as VBoxContainer
export(NodePath) onready var header = get_node(header) as HBoxContainer
export(NodePath) onready var group_note = get_node(group_note) as RichTextLabel
export(PackedScene) var animation_source


func _ready():
	confirm.connect("action_confirmed", self, "delete_confirmed")


func _on_Tree_select(id, selected=false):
	show()
	get_parent().show()
	var character = CharacterHandler.get_item(id)
	if character:
		if selected:
			if !CharacterHandler.selection.has(character):
				CharacterHandler.selection.append(character)
		elif CharacterHandler.selection.has(character):
			CharacterHandler.selection.erase(character)
	# text
	if len(CharacterHandler.selection) > 1:
		set_name("Multiple Selected", true)
	elif len(CharacterHandler.selection) < 1: set_name("", true)
	else: set_name()
	# single item selected
	if len(CharacterHandler.selection) == 1:
		# group
		if CharacterHandler.selection[0].is_group: group_note.show()
		else: group_note.hide()
	else: group_note.hide()
	# root
	if len(CharacterHandler.selection) == 1 and CharacterHandler.selection[0].id == 0:
		header.hide()
		description.hide()
	else:
		header.show()
	
	if len(CharacterHandler.selection) < 1: return
	colour_picker.color = CharacterHandler.selection[0].colour
	
	for c in animation_container.get_children(): c.queue_free()
	
	var animation_names = get_common_animations()
	for animation in animation_names:
		var animations = []
		for item in CharacterHandler.selection:
			animations += item.get_all_animations(animation)
		create(animations)

func set_name(text="", read_only=false):
	if read_only:
		name_edit.hide()
		name_label.show()
		name_edit.set("custom_colors/font_color", Color("ffffff"))
		description.hide()
		if text == "": description.text = ""
		else: description.text = get_description()
	else:
		name_label.hide()
		name_edit.show()
		name_edit.set("custom_colors/font_color",CharacterHandler.selection[0].colour)
		text = CharacterHandler.selection[0].name
		description.show()
		description.text = CharacterHandler.selection[0].description
	name_edit.text = text
	name_label.text = text
	description.emit_signal("text_changed")

func get_description():
	var c_count = 0
	var g_count = 0
	for item in CharacterHandler.selection:
		if item.is_group: g_count += 1
		else: c_count += 1
	if g_count == 0: return str(c_count)+" characters selected."
	elif c_count == 0: return str(g_count)+" groups selected."
	else:
		var c_suffix = ""
		if c_count > 1: c_suffix = "s"
		var g_suffix = ""
		if g_count > 1: g_suffix = "s"
		return str(c_count)+" character"+c_suffix+" and "+\
				str(g_count)+" group"+g_suffix+" selected."


func _on_Name_text_changed(new_text):
	if len(CharacterHandler.selection) == 0: return
	CharacterHandler.selection[0].name = new_text
	emit_signal("update_item")

func change_colour(group, colour, is_subresource=true):
	for item in group:
		if item.id == 0: continue
		if is_subresource and item.colour != item.parent.colour: continue
		if item.is_group: change_colour(item.get_members(), colour)
		item.colour = colour
		emit_signal("update_item", item.id)

func _on_Colour_color_changed(color):
	change_colour(CharacterHandler.selection, color, false)
	if len(CharacterHandler.selection) == 1: name_edit.set("custom_colors/font_color", color)


func _on_Description_text_changed():
	if len(CharacterHandler.selection) != 1: return
	CharacterHandler.selection[0].description = description.text



func create(animations):
	var new_animation = animation_source.instance()
	new_animation.animations = animations
	new_animation.connect("confirm", confirm, "confirm")
	confirm.connect("action_confirmed", new_animation, "delete")
	animation_container.add_child(new_animation)


func _on_AddAnimation_pressed():
	var animations = []
	for item in CharacterHandler.selection:
		animations += item.create_animation()
	if len(animations) == 0: return
	create(animations)

func get_common_animations():
	var result = []
	for animation in CharacterHandler.selection[0].animations:
		result.append(animation.name)
	for item in CharacterHandler.selection:
		var animations = []
		for a in item.animations: animations.append(a.name)
		for a in result:
			if not a in animations: result.erase(a)
	return result


func _on_Delete_pressed():
	if len(CharacterHandler.selection) == 1:
		var character = CharacterHandler.selection[0]
		if character.is_group:
			confirm.confirm(self,"Delete Group")
		else:
			confirm.confirm(self,"Delete Character")
	elif len(CharacterHandler.selection) > 1:
		confirm.confirm(self,"Delete Characters")

func delete_confirmed(node):
	if node != self: return
	CharacterHandler.delete_selection()
	CharacterHandler.emit_signal("update")
