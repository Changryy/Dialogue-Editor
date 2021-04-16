extends ItemHandler

const DEFAULT_CLUE_NAME = "New Clue"


func _ready():
	item_class = Clue
	var root = create("Clues",null,true)
	
	sort()
