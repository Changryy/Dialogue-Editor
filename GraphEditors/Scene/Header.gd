extends HBoxContainer

export(NodePath) onready var g = get_node(g) as GraphEdit
export(Array, PackedScene) var nodes
export(NodePath) var clues
export(NodePath) var editor

var types = {
	"text":0,
	"choice":1,
	"custom":2,
	"evidence":3,
	"change_scene":4,
	"add_clue":5
}

func _on_Back_pressed():
	save()
	get_tree().change_scene("res://GraphEditors/Story/StoryEditor.tscn")

func save():
	SceneHandler.editing.actions.clear()
	for node in g.get_children():
		if not node is GraphNode: continue
		var action = {
			position = node.offset,
			size = node.rect_size
		}
		if node.title == "Start":
			action.type = "start"
			action.next = get_next(node)
		elif node.title == "Text":
			text_node(node, action)
		elif node.title == "Choice":
			choice_node(node, action)
		elif node.title == "Custom":
			action.type = "custom"
			action.name = node.get_node("Name").text
			action.description = node.get_node("Description").text
			action.next = get_next(node)
		elif node.title == "Use Evidence":
			evidence_node(node, action)
		elif node.title == "Change Scene":
			action.type = "change_scene"
			action.text = node.get_node("Text").text
			action.next = node.next
		elif node.title == "Add Clue":
			action.type = "add_clue"
			action.next = get_next(node)
			action.clue = null
			if node.clue: action.clue = node.clue.id
	
		SceneHandler.editing.actions.append(action)



func get_next(node, port=0):
	var connections = g.get_connection_list()
	for connection in connections:
		if connection.from == node.name and connection.from_port == port:
			var i = 0
			for c in g.get_children():
				if c.name == connection.to: return i
				if c is GraphNode: i += 1

func text_node(node, action):
	action.type = "text"
	var animation = node.get_animation()
	if animation:
		action.animation = animation.id
		action.character = animation.owner.id
	else:
		action.animation = null
		action.character = null
	action.text = node.get_node("Text").text
	action.next = get_next(node)

func choice_node(node, action):
	action.type = "choice"
	action.next = get_next(node)
	action.skippable = node.get_node("skip").pressed
	action.options = []
	for i in range(node.get_child_count()):
		var line = node.get_child(i)
		if not line is LineEdit: continue
		var option = {}
		option.text = line.text
		option.next = get_next(node, i-1)
		action.options.append(option)

func evidence_node(node, action):
	action.type = "evidence"
	action.next = get_next(node)
	action.default = get_next(node, len(node.clues)+1)
	action.clues = {}
	for i in len(node.clues):
		action.clues[node.clues[i].id] = get_next(node, i+1)

func get_graphnode(idx):
	var i = 0
	for c in g.get_children():
		if c is GraphNode:
			if i == idx: return c
			i += 1

func _ready():
	for action in SceneHandler.editing.actions:
		if action.type == "start":
			g.get_node("Start").offset = action.position
			continue
		var node = nodes[types[action.type]].instance()
		node.offset = action.position
		node.rect_size = action.size
		node.connect("close_node", get_node(editor), "delete_node")
		if action.type == "text":
			node.select(action.character, action.animation)
			node.get_node("Text").text = action.text
		elif action.type == "choice":
			var lines = len(action.options)
			node.rect_size.y = node.get_choice_size(lines)
			if "skippable" in action:
				node.get_node("skip").pressed = action.skippable
			for c in node.get_children():
				if c is LineEdit:
					node.remove_child(c)
					c.queue_free()
			for i in range(lines):
				var option = action.options[i]
				var line = LineEdit.new()
				line.text = option.text
				node.add_child(line)
				node.set_slot(i+node.NORMAL_CHILD_COUNT,false,0,Color("#00aaff"),true,0,Color("#00aaff"))
		elif action.type == "custom":
			node.get_node("Name").text = action.name
			node.get_node("Description").text = action.description
			node.get_node("Description").emit_signal("text_changed")
		elif action.type == "evidence":
			node.connect("edit", get_node(clues), "edit")
			for clue in action.clues:
				node.clues.append(ClueHandler.get_item(clue))
		elif action.type == "change_scene":
			node.get_node("Text").text = action.text
			node.next = action.next
		elif action.type == "add_clue":
			node.connect("edit", get_node(clues), "edit")
			var clue = ClueHandler.get_item(action.clue)
			if clue: node.clues = [clue]
		g.add_child(node)
	
	for a in range(len(SceneHandler.editing.actions)):
		var action = SceneHandler.editing.actions[a]
		var node = get_graphnode(a)
		if !node: continue
		if action.type in ["start","text","custom","add_clue"] and action.next != null:
				g.connect_node(node.name,0,get_graphnode(action.next).name,0)
		elif action.type == "choice":
			if "next" in action and action.next != null:
				g.connect_node(node.name,0,get_graphnode(action.next).name,0)
			for i in range(len(action.options)):
				var option = action.options[i]
				if option.next != null:
					g.connect_node(node.name,i+1,get_graphnode(option.next).name,0)
		elif action.type == "evidence":
			if action.next != null:
				g.connect_node(node.name,0,get_graphnode(action.next).name,0)
			if action.default != null:
				g.connect_node(node.name,len(action.clues)+1,get_graphnode(action.default).name,0)
			var i = 0
			for clue in action.clues:
				var next = action.clues[clue]
				if next != null:
					next = get_graphnode(next)
				if next is GraphNode:
					g.connect_node(node.name,i+1,next.name,0)
				i += 1


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save()
		if FileHandler.path:
			FileHandler.save_project()
			get_tree().quit()
		else: get_tree().change_scene("res://GraphEditors/Story/StoryEditor.tscn")


func _input(event):
	if Input.is_action_just_pressed("save"):
		save()
		if FileHandler.path: FileHandler.save_project()
