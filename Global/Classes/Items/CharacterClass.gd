extends Item
class_name Character

var animation_index = 0
var animations = []



func create_animation():
	var animation = CharacterAnimation.new()
	animation.id = animation_index
	animation_index += 1
	animation.owner = self
	animations.append(animation)
	var result = [animation]
	for c in get_members():
		result += c.create_animation()
	return result

func delete(animation):
	if !animation: return
	for c in get_members():
		c.delete(c.get_animation(animation.name))
	animations.erase(animation)
	animation.free()

func get_animation(animation_name):
	for animation in animations:
		if animation.name == animation_name:
			return animation
	return null

func get_all_animations(animation_name):
	var result = []
	for c in get_members():
		result += c.get_all_animations(animation_name)
	result.append(get_animation(animation_name))
	return result



