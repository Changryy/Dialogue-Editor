extends HBoxContainer

var animations = []


func _ready():
	if len(animations) == 0: return
	$Name.text = animations[0].name
	set_colour(animations[0].colour)


func set_colour(new_colour):
	if new_colour == Color("ffffff"): new_colour = Color("262c3b")
	var style = StyleBoxFlat.new()
	style.bg_color = new_colour
	$Name.set("custom_styles/normal", style)
	$Name.set("custom_styles/focus", style)


func _on_Colour_color_changed(color):
	set_colour(color)
	for animation in animations:
		animation.colour = color



func _on_Name_text_changed(new_text):
	for a in animations: a.name = new_text


func _on_Delete_pressed():
	for a in animations:
		if !is_instance_valid(a): continue
		a.owner.delete(a)
