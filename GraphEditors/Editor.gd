extends Control

export(NodePath) onready var g = get_node(g) as GraphEdit
export(NodePath) onready var add_node = get_node(add_node) as PopupMenu
export(NodePath) var clues
export(NodePath) var confirm

export(Array, PackedScene) var scenes
export(String, "story", "scene") var type = "scene"

var selected = []

const DIST = Vector2(30,30)
const TRESH = 100

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
func create_node(id, pos=null):
	var node = scenes[id].instance()
	if pos: node.offset = pos
	else: node.offset = (add_node.rect_position + g.scroll_offset) / g.zoom - g.rect_global_position
	
	if node.type == node.TYPES.scene:
		node.connect("change_colour", self, "colour")
		node.confirm = get_node(confirm)
	elif clues and node.type == node.TYPES.evidence: node.connect("edit", get_node(clues), "edit")
	node.connect("close_node", self, "delete_node")
	g.add_child(node)
	return node

# connect node
func connect_node(from, from_slot, to, to_slot):
	var node = g.get_node(from)
	if not node.is_in_group("polyconnectable"): disconnect_slot(from, from_slot)
	if node.name == "Start" and type == "story":
		SceneHandler.start = g.get_node(to).scene.id
	if node.name != "Start" and node.type == node.TYPES.scene:
		if node.scene.is_custom:
			node.scene.next.append(g.get_node(to).scene.id)
		else:
			var slots = node.update_slots()
			for i in range(len(slots)):
				var action = slots[i]
				if i == from_slot:
					action.next = g.get_node(to).scene.id
					break
	
	g.connect_node(from, from_slot, to, to_slot)

# disconnect node
func disconnect_node(from, from_slot, to, to_slot):
	var node = g.get_node(from)
	if node.name == "Start" and type == "story":
		SceneHandler.start = null
	if node.name != "Start" and node.type == node.TYPES.scene:
		if node.scene.is_custom:
			node.scene.next.erase(g.get_node(to).scene.id)
		else:
			var slots = node.update_slots()
			for i in range(len(slots)):
				var action = slots[i]
				if i+1 == from_slot:
					action.next = null
					break
	g.disconnect_node(from, from_slot, to, to_slot)

# selection
func select(node): if not node in selected: selected.append(node)
func deselect(node): if node in selected: selected.erase(node)


# change colour of selection (signal)
func colour(color):
	if len(selected) <= 1: return
	for node in selected:
		if node and node.is_in_group("colourful"): node.colour(color)


# disconnect everything from a slot on a node
func disconnect_slot(node, slot, is_left_slot=false):
	for c in g.get_connection_list():
		if c.from == node and c.from_port == slot and !is_left_slot:
			disconnect_node(node, slot, c.to, c.to_port)
		elif c.to == node and c.to_port == slot and is_left_slot:
			disconnect_node(c.from, c.from_port, node, slot)

# delete node (signal)
func delete_node(node):
	for c in g.get_connection_list():
		if c.from == node.name or c.to == node.name:
			g.disconnect_node(c.from, c.from_port, c.to, c.to_port)
	if node in selected: selected.erase(node)
	g.remove_child(node)
	node.queue_free()


func adjust_pos(pos):
	for c in g.get_children():
			if c is GraphNode and (c.offset-pos).length() < TRESH:
				pos.y += c.rect_size.y + DIST.y
				pos = adjust_pos(pos)
	return pos

func _input(event):
	if Input.is_action_just_pressed("add_text") and type == "scene" and len(selected) > 0:
		var prev = selected[0]
		var pos = prev.offset + Vector2(prev.rect_size.x + DIST.x, 0)
		pos = adjust_pos(pos)
		var node = create_node(0, pos)
		var found_connection = false
		var slot = -1
		for i in range(prev.get_child_count()):
			if prev.is_slot_enabled_right(i):
				slot += 1
				var connected = false
				for c in g.get_connection_list():
					if c.from == prev.name and c.from_port == slot:
						connected = true
						break
				if not connected:
					connect_node(prev.name,slot,node.name,0)
					found_connection = true
					break
		if not found_connection: delete_node(node)
