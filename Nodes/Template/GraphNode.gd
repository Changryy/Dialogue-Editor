extends GraphNode

const LINE = 23 # pixels from line to line
const OFFSET = Vector2(28,10) # pixels offset, top / bottom

export(String, "Normal", "Options") var type

func _on_Node_close_request(): queue_free()
func _on_Node_resize_request(new_minsize):
	rect_size = new_minsize
	for c in get_children():
		if c.is_in_group("big"):
			c.rect_min_size.y = new_minsize.y - c.rect_position.y - OFFSET.y
	
	if type != "Options": return

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
