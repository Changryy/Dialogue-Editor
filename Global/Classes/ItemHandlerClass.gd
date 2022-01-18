extends Node
class_name ItemHandler
signal update

const DEFAULT_GROUP_NAME = "Group"

var items = []
var selection = []
var deletion = []
var item_index = 0
var item_class

func sort_items(a, b):
		# store original depth
		var a_depth = a.depth
		var b_depth = b.depth
		
		# ignore root
		if a.id == 0: return true
		elif b.id == 0: return false
		
		# common depth
		while a.depth > b.depth:
			a = a.parent
		while b.depth > a.depth:
			b = b.parent
		
		# common parent
		while a.parent != b.parent:
			a = a.parent
			b = b.parent
		
		# if same use depth
		if a.id == b.id: return a_depth < b_depth
		
		# compare index
		if a.index < b.index: return true
		return false

func create(name="",parent=null,is_group=false,is_collapsed=false):
	if !parent: parent = get_item()
	var item = item_class.new()
	item.handler = self
	item.id = item_index
	item_index += 1
	item.name = name
	item.parent = parent
	item.is_group = is_group
	item.is_collapsed = is_collapsed
	if parent: item.index = len(parent.get_members())
	items.append(item)
	return item

func delete(parent_item=null):
	if parent_item: delete_recursive(parent_item)
	while len(deletion) > 0:
		var item = deletion[0]
		if item in items: items.erase(item)
		if item in selection: selection.erase(item)
		deletion.erase(item)
		item.free()
	emit_signal("update")


func delete_recursive(item):
	if item.is_group:
		for x in items:
			if x.parent == item: delete_recursive(x)
	deletion.append(item)

func delete_selection():
	for item in selection:
		delete_recursive(item)
	delete()

func get_item(id=0):
	if id == 0 and len(items) > 0: return items[0]
	for item in items:
		if item.id == id: return item
	return null

func move(parent, idx=0):
	for item in selection:
		if item.parent == parent and item.index < idx:
			idx -= 1
	idx = max(idx, 0)
	selection.sort_custom(self, "sort_items")
	var top = selection[0].depth
	for item in selection:
		top = min(top, item.depth)
	
	var main_index = idx
	
	for item in selection:
		var is_subresource = false
		for x in selection:
			if item.parent == x: is_subresource = true
		if is_subresource: continue
		item.parent = parent
		item.just_moved = true
		item.index = idx
		idx += 1
	var prev_items = parent.get_members()
	var delete = []
	for item in prev_items:
		if item in selection:
			delete.append(item)
	for item in delete: prev_items.erase(item)
	var new_len = len(parent.get_members()) - len(prev_items)
	for item in prev_items:
		if item.index >= main_index:
			item.index += new_len
	
	for item in items: item.fix_index()
	sort()
	emit_signal("update")

func _input(event):
	if Input.is_action_just_pressed("group") and len(selection) > 0:
		var parent = selection[0]
		for item in selection:
			if item.depth < parent.depth:
				parent = item
		if parent.id == 0: return
		var group = create(DEFAULT_GROUP_NAME,parent.parent,true,true)
		var siblings = parent.parent.get_members()
		siblings.sort_custom(self, "sort_items")
		for item in siblings:
			if item in selection:
				group.index = item.index
				group.just_moved = true
				break
		move(group)

func sort():
	items.sort_custom(self, "sort_items")

func save():
	var result = []
	for item in items:
		result.append(item.save())
	return result

func load_items(new_items):
	items.clear()
	for item in new_items:
		item = dict2inst(item)
		item.handler = self
		item.parent = get_item(item.parent)
		items.append(item)
