extends ImprovedTree

func _ready():
	init(ClueHandler, ClueHandler.DEFAULT_CLUE_NAME)



func _on_AddClue_pressed():
	var item = create(ClueHandler.create())
	item.set_text(0,ClueHandler.DEFAULT_CLUE_NAME)
