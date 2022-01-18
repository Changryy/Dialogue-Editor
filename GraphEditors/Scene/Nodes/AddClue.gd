extends "res://GraphEditors/NodeTemplate/GraphNode.gd"
signal edit(node, type)

var clues = []
var clue

func _ready():
	update()

func _on_Select_pressed():
	emit_signal("edit", self, true)

func update():
	if len(clues) == 0:
		$Clue.text = "No Clue Selected"
		return
	clue = clues[0]
	clues.clear()
	$Clue.text = clue.name
	$Clue.modulate = clue.colour
