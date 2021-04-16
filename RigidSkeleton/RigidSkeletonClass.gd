extends Skeleton2D
class_name RigidSkeleton2D
const STRENGTH_MULTIPLIER = 1

export(NodePath) onready var body = get_node(body) as PhysicsBody2D
export(float) var gravity_scale = 1.0
export(float) var damp = 1.0
export(float, 0, 16) var softness = 0.0
export(float) var strength = 1
export(Curve) var strength_curve
export(int, LAYERS_2D_PHYSICS) var collision_layer
export(int, LAYERS_2D_PHYSICS) var collision_mask

onready var bones = Node2D.new()


func _ready():
	bones.name = "RigidBones"
	strength *= STRENGTH_MULTIPLIER
	if strength_curve == null:
		strength_curve = Curve.new()
		strength_curve.add_point(Vector2(0,1))
	for bone in get_children():
		var new_bone = KinematicBody2D.new()
		new_bone.position = bone.position
		bones.add_child(new_bone)
		for c in bone.get_children():
			if c is Bone2D: create(c, new_bone)
	
	body.call_deferred("add_child", bones)




func create(bone, parent):
	# generate self
	var new_bone := RigidBone2D.new()
	var pos = bone.global_position-global_position
	new_bone.init(bone,parent,gravity_scale,damp,collision_layer,collision_mask,pos)
	bones.add_child(new_bone)
	bones.add_child(new_bone.create_pin(softness))

	# generate children
	var child_count = 0
	for c in bone.get_children():
		if c is Bone2D: child_count += 1
	if child_count == 0: new_bone.calibrate(strength_curve, strength)
	else:
		for c in bone.get_children():
			if c is Bone2D: create(c, new_bone)




