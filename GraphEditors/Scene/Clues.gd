extends VBoxContainer

export(NodePath) onready var tree = get_node(tree) as Tree

var editing
var items = []
var select_single = false


func _ready():
	tree.connect("item_edited", self, "item_edited")


func edit(node, single=false):
	select_single = single
	editing = node
	draw_tree()
	show()


func draw_tree():
	tree.clear()
	items.clear()
	for c in ClueHandler.items: create(c)

func create(item):
	var parent = null
	if item.parent: parent = get_item(item.parent.id)
	var tree_item = tree.create_item(parent)
	tree_item.set_text(0,item.name)
	if item.name == "":
		if item.is_group: tree_item.set_text(0,ClueHandler.DEFAULT_GROUP_NAME)
		else: tree_item.set_text(0,ClueHandler.DEFAULT_CLUE_NAME)
	tree_item.set_metadata(0,item.id)
	tree_item.set_custom_color(0,item.colour)
	tree_item.collapsed = item.is_collapsed
	if !item.is_group:
		tree_item.set_cell_mode(1,TreeItem.CELL_MODE_CHECK)
		tree_item.set_editable(1,true)
		if item in editing.clues:
			tree_item.set_checked(1,true)
	items.append(tree_item)
	return tree_item

func get_item(id):
	for tree_item in items:
		if tree_item.get_metadata(0) == id:
			return tree_item
	return null


func _on_Done_pressed():
	editing.clues.clear()
	for item in items:
		if item.is_checked(1):
			var clue = ClueHandler.get_item(item.get_metadata(0))
			if clue and !clue.is_group: editing.clues.append(clue)
	editing.update()
	hide()
	tree.clear()


func item_edited():
	if select_single:
		_on_Done_pressed()
