extends VBoxContainer
signal update_item(id)

export(NodePath) onready var name_edit = get_node(name_edit) as LineEdit
export(NodePath) onready var name_label = get_node(name_label) as Label
export(NodePath) onready var colour_picker = get_node(colour_picker) as ColorPickerButton
export(NodePath) onready var description = get_node(description) as TextEdit
export(NodePath) onready var animation_container = get_node(animation_container) as VBoxContainer
export(NodePath) onready var header = get_node(header) as HBoxContainer
export(NodePath) onready var group_note = get_node(group_note) as RichTextLabel
export(PackedScene) var animation_source

func _on_Tree_select(id, selected=false):
	var character = CharacterHandler.get_item(id)
	if character:
		if selected:
			if !CharacterHandler.selection.has(character):
				CharacterHandler.selection.append(character)
		elif CharacterHandler.selection.has(character):
			CharacterHandler.selection.erase(character)
	# text
	if len(CharacterHandler.selection) > 1:
		set_name("Multiple Characters Selected", true)
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
		description.show()
	
	if len(CharacterHandler.selection) < 1: return
	colour_picker.color = CharacterHandler.selection[0].colour
	
	for c in animation_container.get_children(): c.queue_free()
	var animations = CharacterHandler.selection[0].animations
	for item in CharacterHandler.selection:
		for animation in animations:
			if not animation in item.animations:
				animations.erase(animation)
	for animation in animations:
		create(animation)

func set_name(text="", read_only=false):
	if read_only:
		name_edit.hide()
		name_label.show()
		name_edit.set("custom_colors/font_color", Color("ffffff"))
		description.readonly = true
		if text == "": description.text = ""
		else: description.text = get_description()
	else:
		name_label.hide()
		name_edit.show()
		name_edit.set("custom_colors/font_color",CharacterHandler.selection[0].colour)
		text = CharacterHandler.selection[0].name
		description.readonly = false
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
		if is_subresource and item.colour != item.inherits.colour: continue
		if item.is_group: change_colour(item.get_members(), colour)
		item.colour = colour
		emit_signal("update_item", item.id)

func _on_Colour_color_changed(color):
	change_colour(CharacterHandler.selection, color, false)
	if len(CharacterHandler.selection) == 1: name_edit.set("custom_colors/font_color", color)


func _on_Description_text_changed():
	if len(CharacterHandler.selection) != 1: return
	CharacterHandler.selection[0].description = description.text


func _on_Tree_deselect():
	header.hide()
	group_note.hide()
	description.hide()


func create(animation):
	var new_animation = animation_source.instance()
	new_animation.data = animation
	animation_container.add_child(new_animation)


func _on_AddAnimation_pressed():
	pass


