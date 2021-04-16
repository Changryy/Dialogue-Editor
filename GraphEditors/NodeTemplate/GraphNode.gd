extends GraphNode

signal change_colour(color)
signal close_node(node)

const LINE = 23 # pixels from line to line
const OFFSET = Vector2(28,10) # pixels offset, top / bottom
const STYLES = ["commentfocus","comment","frame","selectedframe",
"position","defaultfocus","breakpoint","defaultframe"]

enum TYPES {none,choice,scene}

export(TYPES) var type = TYPES.none
export(NodePath) var colour_path
var colour_picker : ColorPickerButton
export(NodePath) var characters

var is_hovered = false

func _ready(): if colour_path: colour_picker = get_node(colour_path)


func _on_Node_close_request(): emit_signal("close_node", self)



func _on_Node_resize_request(new_minsize):
	rect_size = new_minsize
	for c in get_children():
		if c.is_in_group("big"):
			c.rect_min_size.y = new_minsize.y - c.rect_position.y - OFFSET.y
	
	if type == TYPES.choice: choice_resize(new_minsize)


func choice_resize(new_minsize):
	var new_size = new_minsize.y - OFFSET.x - OFFSET.y
	new_size /= LINE
	new_size = max(int(new_size),1)
	for i in range(max(get_child_count(),new_size)):
		if i >= new_size: get_child(i).queue_free()
		elif i >= get_child_count():
			var c = LineEdit.new()
			add_child(c)
			set_slot(i,false,0,Color("#00aaff"),true,0,Color("#00aaff"))
	new_size = new_size*LINE + OFFSET.x + OFFSET.y
	rect_size.y = new_size



func _on_Colour_color_changed(color):
	emit_signal("change_colour", color)
	colour(color)

func colour(color):
	# update preview
	colour_picker.color = color
	
	# style colour
	for x in STYLES:
		var style = get("custom_styles/"+x).duplicate()
		style.border_color = color
		set("custom_styles/"+x, style)
	
	# character style colour
	if characters:
		var c = get_node(characters)
		var style = c.get("custom_styles/normal")
		style.border_color = color
		c.set("custom_styles/normal", style)
		c.set("custom_styles/focus", style)
	
	
	# slot colour
	for i in range(get_child_count()-1):
		if i == 0: set_slot(i,true,0,color,false,0,color)
		else: set_slot(i,false,0,color,is_slot_enabled_right(i),0,color)


