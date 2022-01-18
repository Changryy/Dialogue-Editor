extends FileDialog

export(NodePath) onready var g = get_node(g) as GraphEdit
export(Array, PackedScene) var scenes
export(NodePath) onready var confirm = get_node(confirm)
export(NodePath) onready var editor = get_node(editor)
export(NodePath) onready var indicator = get_node(indicator)

enum {
	SAVE,
	LOAD,
	EXPORT
}


var status = SAVE


func _ready():
	get_tree().set_auto_accept_quit(false)
	FileHandler.connect("indicate", self, "indicate")
	connect("file_selected", self, "file_selected")
	confirm.connect("action_confirmed", self, "quit")
	load_graph()

func load_graph():
	for node in g.get_children():
		if node is GraphNode and node.name != "Start":
			editor.delete_node(node)
	for scene in SceneHandler.scenes:
		var node
		if scene.is_custom: node = scenes[1].instance()
		else: node = scenes[0].instance()
		node.scene = scene
		node.confirm = confirm
		node.get_node("Text").text = scene.description
		node.connect("change_colour", editor, "colour")
		node.connect("close_node", editor, "delete_node")
		g.add_child(node)
	for scene in SceneHandler.scenes:
		var node = get_graphnode(scene.id)
		if !node: continue
		if scene.is_custom:
			for next in scene.next:
				var next_node = get_graphnode(next)
				g.connect_node(node.name,0,next_node.name,0)
		else:
			var slots = node.update_slots()
			for i in range(len(slots)):
				var action = slots[i]
				if action.next != null:
					var next_node = get_graphnode(action.next)
					g.connect_node(node.name,i,next_node.name,0)
	
	if SceneHandler.start != null:
		g.connect_node("Start",0,get_graphnode(SceneHandler.start).name,0)
	g.get_node("Start").offset = SceneHandler.start_position

func get_graphnode(scene):
	for c in g.get_children():
		if c is GraphNode and c.name != "Start" and c.scene.id == scene:
			return c

func _on_Save_pressed():
	if FileHandler.path:
		FileHandler.save_project()
		return
	status = SAVE
	mode = FileDialog.MODE_SAVE_FILE
	window_title = "Save File"
	popup_centered()

func _input(event):
	if Input.is_action_just_pressed("accept") and visible:
		file_selected()
	if Input.is_action_just_pressed("save") and !visible:
		_on_Save_pressed()

func file_selected(a=null):
	FileHandler.path = current_path
	if status == SAVE: FileHandler.save_project()
	elif status == LOAD:
		FileHandler.load_project()
		load_graph()

func _on_FileDialog_dir_selected(dir):
	if status == EXPORT: FileHandler.export_json(dir)

func _on_Open_pressed():
	status = LOAD
	mode = FileDialog.MODE_OPEN_FILE
	window_title = "Open File"
	popup_centered()


func _on_Start_offset_changed():
	SceneHandler.start_position = g.get_node("Start").offset



func indicate(message):
	indicator.text = message
	indicator.show()
	$Timer.start(0.3)


func _on_Timer_timeout(): indicator.hide()


func _on_Export_pressed():
	status = EXPORT
	mode = FileDialog.MODE_OPEN_DIR
	window_title = "Choose export location"
	popup_centered()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if FileHandler.path:
			FileHandler.save_project()
			quit()
		else: confirm.confirm(self, "Quit")

func quit(node=self):
	if node == self:
		get_tree().quit()
