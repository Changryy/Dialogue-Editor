extends Control




func hide_all():
	hide()
	for c in get_children(): c.hide()


func _on_Tree_deselect(): hide_all()
