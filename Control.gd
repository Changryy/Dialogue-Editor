extends Control

var scenes = {
	0:preload("res://Nodes/Text.tscn"),
	1:preload("res://Nodes/Options.tscn"),
	2:preload("res://Nodes/Action.tscn"),
	3:preload("res://Nodes/ChangeScene.tscn")
}


func _on_GraphEdit_popup_request(position):
	$PopupMenu.rect_position = position
	$PopupMenu.popup()


func _on_PopupMenu_id_pressed(id):
	var node = scenes[id].instance()
	node.offset = $PopupMenu.rect_position - Vector2(10,0) + $GraphEdit.scroll_offset
	$GraphEdit.add_child(node)


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	$GraphEdit.connect_node(from, from_slot, to, to_slot)
