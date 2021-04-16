extends Control

export(NodePath) onready var g = get_node(g) as GraphEdit
export(NodePath) onready var add_node = get_node(add_node) as PopupMenu

export(Array, PackedScene) var scenes


var selected = []


func _ready():
	add_node.connect("id_pressed", self, "create_node")
	g.connect("popup_request", self, "popup")
	g.connect("connection_request", self, "connect_node")
	g.connect("disconnection_request", self, "disconnect_node")
	g.connect("node_selected", self, "select")
	g.connect("node_unselected", self, "deselect")


# select node
func popup(position):
	add_node.rect_position = position
	add_node.popup()


# create node
func create_node(id):
	var node = scenes[id].instance()
	node.offset = (add_node.rect_position + g.scroll_offset) / g.zoom
	node.connect("change_colour", self, "colour")
	node.connect("close_node", self, "delete_node")
	g.add_child(node)

# connect node
func connect_node(from, from_slot, to, to_slot):
	var node = g.get_node(from)
	if not node.is_in_group("polyconnectable"): disconnect_slot(from, from_slot)
	g.connect_node(from, from_slot, to, to_slot)

# disconnect node
func disconnect_node(from, from_slot, to, to_slot):
	g.disconnect_node(from, from_slot, to, to_slot)

# selection
func select(node): selected.append(node)
func deselect(node): selected.erase(node)


# change colour of selection (signal)
func colour(color):
	if len(selected) <= 1: return
	for node in selected:
		if node.is_in_group("colourful"): node.colour(color)


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



