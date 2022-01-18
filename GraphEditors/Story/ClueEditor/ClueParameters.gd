extends VBoxContainer
signal update_item(id)

export(NodePath) onready var confirm = get_node(confirm) as ConfirmationDialog
export(NodePath) onready var name_edit = get_node(name_edit) as LineEdit
export(NodePath) onready var name_label = get_node(name_label) as Label
export(NodePath) onready var colour_picker = get_node(colour_picker) as ColorPickerButton
export(NodePath) onready var body = get_node(body) as VSplitContainer
export(NodePath) onready var obtainment = get_node(obtainment) as TextEdit
export(NodePath) onready var description = get_node(description) as TextEdit


func _ready():
	confirm.connect("action_confirmed", self, "delete")

func _on_Tree_select(id, selected):
	show()
	get_parent().show()
	var clue = ClueHandler.get_item(id)
	if clue:
		if selected:
			if !ClueHandler.selection.has(clue):
				ClueHandler.selection.append(clue)
		elif ClueHandler.selection.has(clue):
			ClueHandler.selection.erase(clue)
	
	
	if len(ClueHandler.selection) > 1:
		name_edit.hide()
		name_label.show()
		body.hide()
		colour_picker.color = ClueHandler.selection[0].colour
	
	elif len(ClueHandler.selection) == 1:
		clue = ClueHandler.selection[0]
		colour_picker.color = clue.colour
		name_edit.show()
		name_label.hide()
		body.show()
		name_edit.set("custom_colors/font_color",clue.colour)
		name_edit.text = clue.name
		obtainment.text = clue.obtainment
		description.text = clue.description
		obtainment.emit_signal("text_changed")
		description.emit_signal("text_changed")
		
		if clue.is_group:
			obtainment.hide()
		else: obtainment.show()


func change_colour(group, colour, is_subresource=true):
	for item in group:
		if item.id == 0: continue
		if is_subresource and item.colour != item.parent.colour: continue
		if item.is_group: change_colour(item.get_members(), colour)
		item.colour = colour
		emit_signal("update_item", item.id)

func _on_Colour_color_changed(color):
	change_colour(ClueHandler.selection, color, false)
	if len(ClueHandler.selection) == 1: name_edit.set("custom_colors/font_color", color)


func _on_Obtainment_text_changed():
	if len(ClueHandler.selection) > 0: ClueHandler.selection[0].obtainment = obtainment.text

func _on_Description_text_changed():
	if len(ClueHandler.selection) > 0: ClueHandler.selection[0].description = description.text

func _on_Name_text_changed(new_text):
	if len(ClueHandler.selection) > 0: ClueHandler.selection[0].name = new_text
	emit_signal("update_item")


func _on_Delete_pressed():
	if len(ClueHandler.selection) > 1:
		confirm.confirm(self,"Delete Clues")
	elif len(ClueHandler.selection) == 1:
		if ClueHandler.selection[0].is_group:
			confirm.confirm(self,"Delete Group")
		else: confirm.confirm(self,"Delete Clue")

func delete(node):
	if node != self: return
	ClueHandler.delete_selection()
