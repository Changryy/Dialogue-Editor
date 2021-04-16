extends KinematicBody2D

var speed = 100

func _physics_process(delta):
	position = get_global_mouse_position()
#	print(position,", ",get_node("../KinematicBody2D2").position)
