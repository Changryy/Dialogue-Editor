tool
extends TextEdit

export(String) var placeholder setget text_update
export(float, 0, 1) var alpha = 0.6 setget alpha_update

func text_update(new_text):
	placeholder = new_text
	if has_node("Label"): $Label.text = placeholder

func alpha_update(new_alpha):
	alpha = new_alpha
	if has_node("Label"): $Label.modulate = Color(1,1,1,alpha)

func visibility_update():
	if has_node("Label"):
		if len(text) > 0: $Label.hide()
		else: $Label.show()

func _ready():
	connect("text_changed", self, "visibility_update")
	emit_signal("text_changed")
