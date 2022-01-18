extends "res://GraphEditors/NodeTemplate/GraphNode.gd"
signal change_colour(color)

var scene
var confirm

func _ready():
	if !scene:
		scene = SceneHandler.create_scene()
		scene.position = offset
		scene.size = rect_size
		scene.is_custom = true
	else:
		offset = scene.position
		rect_size = scene.size
		colour(scene.colour)
		$Header/Name.text = scene.name
		$Text.text = scene.description
		$Text.emit_signal("text_changed")
	connect("resize_request", self, "resize")
	connect("offset_changed", self, "reposition")
	emit_signal("resize_request", rect_size)

func colour(color):
	# update preview
	$Header/Colour.color = color
	scene.colour = color
	# style colour
	for x in STYLES:
		var style = get("custom_styles/"+x).duplicate()
		style.border_color = color
		set("custom_styles/"+x, style)
	
	# slot colour
	set_slot(0,true,0,color,true,0,color)

func resize(new_size): scene.size = rect_size
func reposition(): scene.position = offset


func _on_Colour_color_changed(color):
	emit_signal("change_colour", color)
	colour(color)


func _on_Custom_close_request():
	SceneHandler.delete_scene(scene)
	emit_signal("close_node", self)


func _on_Name_text_changed(new_text):
	if scene: scene.name = new_text

func _on_Text_text_changed():
	if scene: scene.description = $Text.text
