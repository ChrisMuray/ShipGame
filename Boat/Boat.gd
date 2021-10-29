extends RigidBody2D

onready var whirlpools = get_parent().get_node("Whirlpools").get_children()
const FORCE = 500
const MAX_SPEED = 2000
onready var respawn_position = position
var reset_state = false

var show_tangent = Vector2()
var show_r = Vector2()
var show_acc = Vector2()
var w

func _ready():
	pass

func _input(e):
	if e is InputEventKey and e.pressed:
		if e.scancode == KEY_SPACE:
			w.frame = 1 if w.frame == 0 else 0
		if e.scancode == KEY_R:
			respawn()

func _physics_process(delta):
	w = find_closest_whirlpool()
	apply_whirlpool_forces(w)
	$AnimatedSprite.playing = linear_velocity.length() > 0
	

func find_closest_whirlpool():
	var count = 0
	var shortest_distance
	var closest_whirlpool
	for i in range(whirlpools.size()):
		var d = (whirlpools[i].position-position).length()
		if i==0 or d < shortest_distance:
			shortest_distance = d
			closest_whirlpool = whirlpools[i]
	return closest_whirlpool

func apply_whirlpool_forces(w):
	if not w:
		return
	var r = w.position - position
	var v = linear_velocity
	if r.length() < 10 or r.length() > 400:
		linear_velocity = lerp(v.length(),0,0.01)*v.normalized()
		rotation_degrees = linear_velocity.angle() * 360 / (2*PI) + 90
		show_r = r
		return
	var acc = Vector2()
	var tangent_direction = Vector2()
	
	#Linear force
	acc += (FORCE / r.length()) * r.normalized()
	
	#Whirly force
	if w.frame == 0:
		var tangent_angle = 0
		if r.cross(v) > 0:
			tangent_angle = PI/2
		elif r.cross(v) < 0:
			tangent_angle = -PI/2
		tangent_direction = r.normalized().rotated(tangent_angle)
		acc += (FORCE/10) / r.length() * tangent_direction
	
	#Vectors that are drawn by Draw.gd
	show_acc = acc
	show_r = r
	show_tangent = tangent_direction
	
	#Actually add  the acceleration
	linear_velocity += acc if w.frame == 0 else -acc
	
	#Point forward
	rotation_degrees = linear_velocity.angle() * 360 / (2*PI) + 90

func respawn():
	reset_state = true

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform2D(0,respawn_position)
		linear_velocity -= linear_velocity
		reset_state = false

#NOT USING this, takes into account ALL the whirlpools
func all_whirlpool_forces():
	for w in whirlpools:
		apply_whirlpool_forces(w)
