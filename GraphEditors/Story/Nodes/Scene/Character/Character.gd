extends Label
signal delete(delete_character)
signal confirm(node, title)

var character


func _process(delta):
	if !character: return
	text = character.name
	modulate = character.colour


func _on_Delete_pressed():
	emit_signal("confirm", self, "Remove Character")
	
	
func delete_confirm(node):
	if node != self: return
	emit_signal("delete", character)
	queue_free()
