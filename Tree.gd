extends ImprovedTree

func _ready():
	init(CharacterHandler, CharacterHandler.DEFAULT_CHARACTER_NAME)


func _on_AddCharacter_pressed():
	var item = create(CharacterHandler.create())
	item.set_text(0,handler.DEFAULT_CHARACTER_NAME)
