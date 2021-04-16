extends Tree
class_name ImprovedTree
signal select(id, selected)
signal deselect

var handler : ItemHandler
var items = []
var default_item_name = ""

func init(new_handler, new_default_name=""):
	handler = new_handler
	default_item_name = new_default_name
	handler.connect("update", self, "draw_tree")
	connect("multi_selected", self, "update_selection")
	connect("item_edited", self, "edit_name")
	connect("nothing_selected", self, "nothing_selected")
	connect("item_collapsed", self, "item_collapsed")
	draw_tree()

func draw_tree():
	clear()
	items.clear()
	handler.selection.clear()
	for c in handler.items: create(c)

func create(item: Item):
	var parent = null
	if item.parent: parent = get_item(item.parent.id)
	var tree_item = create_item(parent)
	tree_item.set_text(0,item.name)
	if item.name == "":
		if item.is_group: tree_item.set_text(0,handler.DEFAULT_GROUP_NAME)
		else: tree_item.set_text(0,default_item_name)
	tree_item.set_metadata(0,item.id)
	if item.id != 0: tree_item.set_editable(0,true)
	tree_item.set_custom_color(0,item.colour)
	tree_item.collapsed = item.is_collapsed
	items.append(tree_item)
	return tree_item

func get_item(id):
	for tree_item in items:
		if tree_item.get_metadata(0) == id:
			return tree_item
	return null

func update_selection(tree_item, column, selected):
	emit_signal("select", tree_item.get_metadata(0), selected)

func edit_name():
	var tree_item = get_selected()
	var id = tree_item.get_metadata(0)
	var item = handler.get_item(id)
	item.name = tree_item.get_text(0)
	update_item(id)
	emit_signal("select", id, true)

func update_item(id=null): # signal
	if not id: id = handler.selection[0].id
	var tree_item = get_item(id)
	if !tree_item: return
	var item = handler.get_item(id)
	# update name
	var new_name = item.name
	if new_name == "":
		if item.is_group: new_name = handler.DEFAULT_GROUP_NAME
		else: new_name = default_item_name
	tree_item.set_text(0, new_name)
	# update colour
	var new_colour = item.colour
	tree_item.set_custom_color(0, new_colour)

func nothing_selected():
	handler.selection.clear()
	get_root().call_recursive("deselect", 0)
	emit_signal("deselect")

func item_collapsed(tree_item):
	var item = handler.get_item(tree_item.get_metadata(0))
	item.is_collapsed = tree_item.is_collapsed()


func get_drag_data(position: Vector2):
	var selected: TreeItem = get_selected()
	if is_instance_valid(selected):
		return 0


func can_drop_data(_pos, data):
	var tree_item = get_item_at_position(_pos)
	var item : Item
	if not tree_item: return true
	item = handler.get_item(tree_item.get_metadata(0))
	if item.is_group: set_drop_mode_flags(3)
	else: set_drop_mode_flags(DROP_MODE_INBETWEEN)
	return true


func drop_data(_pos, data):
	var pos = get_drop_section_at_position(_pos)
	var tree_item = get_item_at_position(_pos)
	var target : Item
	if pos == -100:
		target = handler.get_item()
		pos = 0
	elif tree_item:
		target = handler.get_item(tree_item.get_metadata(0))
	else: return
	
	if target.id == 0: pos = 0
	
	var parent = target.parent as Item
	while parent:
		if parent in handler.selection: return
		parent = parent.parent
	
	if pos == 0: handler.move(target, len(target.get_members()))
	else:
		pos = max(pos, 0)
		handler.move(target.parent, target.index + pos)
