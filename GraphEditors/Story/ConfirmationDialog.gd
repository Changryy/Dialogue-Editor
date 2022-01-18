extends ConfirmationDialog
signal action_confirmed(node)
var node

var text = {
	"Delete Character": "Deleting a character will remove it from all the scenes where it's currently present.\nThis action cannot be undone.",
	"Delete Group": "WARNING: Deleting a group will also delete all it's content. If you DON'T want to delete the content please move it outside the group before deleting it.\nThis action cannot be undone.",
	"Delete Characters": "You are about to delete multiple characters. Deleting a character will remove it from all the scenes where it's currently present.\nThis action cannot be undone.",
	"Delete Animation": "Deleting an animation will remove it from all the nodes where it's being used. Please assign a new animation to those nodes after deleting this animation.\nThis action cannot be undone.",
	"Remove Character": "The character will be removed from the scene, thus also removing it from all the nodes in the scene where it's being used. Please assign a new character to those nodes after removing the current character.\nThis action cannot be undone.",
	"Delete Clue": "Deleting a clue will remove it from all the nodes where it's being used.\nThis action cannot be undone.",
	"Delete Clues": "You are about to delete multiple clues. Deleting a clue will remove it from all the nodes where it's being used.\nThis action cannot be undone.",
	"Delete Scene": "Deleting a scene will delete all the content within the scene.\nThis action cannot be undone.",
	"Quit": "This project has not been saved.\nQuit anyway?"
}


func _ready():
	connect("confirmed", self, "confirmed")

func confirm(for_node,title):
	node = for_node
	window_title = title
	dialog_text = text[title]
	call_deferred("popup_centered")


func confirmed():
	emit_signal("action_confirmed", node)
