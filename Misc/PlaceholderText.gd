tool
extends TextEdit

export(NodePath) var label
export(String) var placeholder setget text_update
export(float, 0, 1) var alpha = 0.6 setget alpha_update

func text_update(new_text):
	placeholder = new_text
	if has_node(label): get_node(label).text = placeholder

func alpha_update(new_alpha):
	alpha = new_alpha
	if has_node(label): get_node(label).modulate = Color(1,1,1,alpha)

func visibility_update():
	if has_node(label):
		if len(text) > 0: get_node(label).hide()
		else: get_node(label).show()

func _ready():
	connect("text_changed", self, "visibility_update")
