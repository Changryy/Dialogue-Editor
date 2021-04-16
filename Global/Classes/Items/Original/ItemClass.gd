extends Object
class_name Item

var name = ""
var description = ""
var colour = Color("ffffff")
var id = 0
var handler

var parent setget reparent
var depth = 0
var is_collapsed = false
var index: int = 0
var just_moved = false
var is_group = false



func reparent(new):
	parent = new
	if new: depth = new.depth+1
	for member in get_members():
		member.reparent(self)

func get_members():
	if !is_group: return []
	var result = []
	for item in handler.items:
		if item.parent == self: result.append(item)
	return result

func fix_index():
	if just_moved or id == 0:
		just_moved = false
		return
	
	var siblings = []
	for sibling in parent.get_members():
		if sibling == self: continue
		siblings.append(sibling.index)
	while index in siblings: index += 1

	for i in range(len(siblings)):
		if i in siblings: continue
		index = i
		break
