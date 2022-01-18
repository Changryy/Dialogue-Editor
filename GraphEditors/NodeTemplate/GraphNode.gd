extends GraphNode
signal close_node(node)

const LINE = 23 # pixels from line to line
const OFFSET = Vector2(72,10) # pixels offset, top / bottom
const STYLES = ["commentfocus","comment","frame","selectedframe",
"position","defaultfocus","breakpoint","defaultframe"]
const NORMAL_CHILD_COUNT = 2

enum TYPES {none,choice,scene,evidence}

export(TYPES) var type = TYPES.none

var next


func _on_Node_close_request():
	if type == TYPES.scene: return
	emit_signal("close_node", self)



func _on_Node_resize_request(new_minsize):
	if type == TYPES.evidence:
		rect_size.x = new_minsize.x
		return
	rect_size = new_minsize
	for c in get_children():
		if c.is_in_group("big"):
			c.rect_min_size.y = new_minsize.y - c.rect_position.y - OFFSET.y
	
	if type == TYPES.choice: choice_resize(new_minsize)


func choice_resize(new_minsize):
	var new_size = new_minsize.y - OFFSET.x - OFFSET.y
	new_size /= LINE
	new_size = max(int(new_size),2)
	for i in range(max(get_child_count()-NORMAL_CHILD_COUNT,new_size)):
		var slot = true
		if i >= new_size:
			slot = false
			get_child(i+NORMAL_CHILD_COUNT).queue_free()
		elif i >= get_child_count()-NORMAL_CHILD_COUNT:
			var c = LineEdit.new()
			add_child(c)
		set_slot(i+NORMAL_CHILD_COUNT,false,0,Color("#00aaff"),slot,0,Color("#00aaff"))
	new_size = get_choice_size(new_size)
	rect_size.y = new_size

func _ready():
	emit_signal("resize_request", rect_size)

func get_choice_size(lines):
	return lines*LINE + OFFSET.x + OFFSET.y



