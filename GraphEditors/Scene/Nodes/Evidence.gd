extends "res://GraphEditors/NodeTemplate/GraphNode.gd"
signal edit(node)
const colour = Color("00ff5b")

var clues = []

func _ready():
	update()

func create(_name, colour=Color.white):
	if _name == "": _name = ClueHandler.DEFAULT_CLUE_NAME
	var label = Label.new()
	label.text = _name
	label.modulate = colour
	label.add_to_group("clue")
	add_child(label)

func update():
	for c in get_children():
		if c.is_in_group("clue"):
			remove_child(c)
			c.queue_free()
	for clue in clues: create(clue.name, clue.colour)
	create("Other")
	for i in range(len(clues)+1): set_slot(i+2,false,0,Color(),true,0,colour)
	rect_size.y = 23 * len(clues) + 97
	


func _on_Button_pressed():
	emit_signal("edit", self)

