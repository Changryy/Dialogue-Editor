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

func get_animation_by_id(animation_id):
	for animation in animations:
		if animation.id == animation_id:
			return animation
	return null

func get_all_animations(animation_name):
	var result = []
	var animation = get_animation(animation_name)
	if animation: result.append(animation)
	for c in get_members():
		result += c.get_all_animations(animation_name)
	return result

func fix_animations():
	var new_animations = []
	for a in animations:
		a = dict2inst(a)
		a.owner = self
		new_animations.append(a)
	animations = new_animations

func save():
	var result = .save()
	result.animations = []
	for a in animations:
		result.animations.append(a.save())
	return result

