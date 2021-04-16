extends Item
class_name Character

var animation_index = 0
var animations = []



func create_animation():
	var animation = CharacterAnimation.new()
	animation.id = animation_index
	animation_index += 1
	animations.append(animation)
	for c in get_members():
		c.create_animation()
	return animation

func set_animation():
	for member in get_members():
		print(member.name)
#		member.set_animation()
