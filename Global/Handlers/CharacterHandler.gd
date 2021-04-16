extends ItemHandler

const DEFAULT_CHARACTER_NAME = "New Character"
const DEFAULT_ANIMATION_NAME = "New Animation"

func _ready():
	item_class = Character
	var root = create("Characters",null,true)
	
	sort()


func _physics_process(delta):
	if Input.is_action_just_pressed("right_click"):
		for item in items:
			print(item.name," - ",item.index)
