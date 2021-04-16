extends HBoxContainer

var data : CharacterAnimation


func _ready():
	if !data: return
	$Name.text = data.name
