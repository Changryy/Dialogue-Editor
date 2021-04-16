extends RigidBody2D
class_name RigidBone2D

const GROUP = "rigidbone"

var velocity : Vector2
var parent : PhysicsBody2D
var shape : SegmentShape2D
var depth = 0
var bone

func init(new_bone, new_parent, gravity, damp, layer, mask, pos: Vector2):
	add_to_group(GROUP)
	gravity_scale = gravity
	parent = new_parent
	bone = new_bone
	global_rotation = bone.global_rotation
	position = pos
	linear_damp = damp
	velocity = (position-parent.position).normalized()
	if parent.is_in_group(GROUP): depth = parent.depth + 1
	collision_layer = layer
	collision_mask = mask
	
	shape = SegmentShape2D.new()
	shape.b = parent.position-position
	
	var hitbox = CollisionShape2D.new()
	hitbox.shape = shape
	#add_child(hitbox)



func create_pin(new_softness):
	var pin = PinJoint2D.new()
	pin.disable_collision = true
	pin.position = parent.position
	pin.softness = new_softness
	pin.node_a = "../" + parent.name
	pin.node_b = "../" + name
	return pin

func calibrate(curve: Curve, multiplier: int, force=Vector2(), max_depth=null):
	if max_depth == null: max_depth = depth
	if max_depth != 0: velocity *= curve.interpolate(depth/max_depth) * multiplier
	if parent.is_in_group(GROUP): parent.calibrate(curve,multiplier,velocity,max_depth)
	velocity -= force


func _integrate_forces(state):
	applied_force = velocity


#func _ready():
#	var remote_transform = RemoteTransform2D.new()
#	remote_transform.update_scale = false
#	remote_transform.update_rotation = false
#	remote_transform.use_global_coordinates = true
#	add_child(remote_transform)
#	remote_transform.remote_path = remote_transform.get_path_to(bone)
	
func _process(delta):
	if bone:
		bone.global_position = global_position
		bone.global_rotation = global_rotation
	#print(get_child(1).global_position,", ",bone.global_position)
