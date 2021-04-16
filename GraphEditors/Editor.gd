extends Control

export(NodePath) onready var g = get_node(g) as GraphEdit
export(NodePath) onready var add_node = get_node(add_node) as PopupMenu

export(Array, PackedScene) var scenes


var selected = []


# select node
func _on_GraphEdit_popup_request(position):
	add_node.rect_position = position
	add_node.popup()


# create node
func _on_PopupMenu_id_pressed(id):
	var node = scenes[id].instance()
	node.offset = (add_node.rect_position + g.scroll_offset) / g.zoom
	node.connect("change_colour", self, "colour")
	node.connect("close_node", self, "delete_node")
	g.add_child(node)

# connect node
func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	var node = g.get_node(from)
	if not node.is_in_group("polyconnectable"): disconnect_slot(from, from_slot)
	g.connect_node(from, from_slot, to, to_slot)

# disconnect node
func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	g.disconnect_node(from, from_slot, to, to_slot)

# selection
func _on_GraphEdit_node_selected(node): selected.append(node)
func _on_GraphEdit_node_unselected(node): selected.erase(node)


# change colour of selection (signal)
func colour(color):
	if len(selected) <= 1: return
	for node in selected:
		if node.is_in_group("colourful"): node.colour(color)

# drag splitter
func _on_Split_dragged(offset):
	$Split.split_offset = offset

# disconnect everything from a slot on a node
func disconnect_slot(node, slot, is_left_slot=false):
	for c in g.get_connection_list():
		if c.from == node and c.from_port == slot and !is_left_slot:
			g.disconnect_node(node, slot, c.to, c.to_port)
		elif c.to == node and c.to_port == slot and is_left_slot:
			g.disconnect_node(c.from, c.from_port, node, slot)

# delete node (signal)
func delete_node(node):
	for c in g.get_connection_list():
		if c.from == node.name or c.to == node.name:
			g.disconnect_node(c.from, c.from_port, c.to, c.to_port)
	node.queue_free()



