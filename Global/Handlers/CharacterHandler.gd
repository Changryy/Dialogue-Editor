extends ItemHandler

const DEFAULT_CHARACTER_NAME = "New Character"
const DEFAULT_ANIMATION_NAME = "New Animation"

func _ready():
	item_class = Character
	var root = create("Characters",null,true)
	
	sort()


func load_items(new_items):
	.load_items(new_items)
	for item in items:
		item.fix_animations()
