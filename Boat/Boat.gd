extends RigidBody2D

onready var whirlpools = get_parent().get_node("Whirlpools").get_children()
const FORCE = 500
const MAX_SPEED = 2000

var show_tangent = Vector2()
var show_r = Vector2()
var show_acc = Vector2()
var w

func _ready():
	linear_velocity = 100*Vector2.UP + 100*Vector2.RIGHT

func _input(e):
	if e is InputEventKey and e.scancode == KEY_SPACE and e.pressed:
		w.frame = 1 if w.frame == 0 else 0

func _physics_process(delta):
	w = find_closest_whirlpool()
	apply_whirlpool_forces(w)
	

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

#NOT USING this, takes into account ALL the whirlpools
func all_whirlpool_forces():
	for w in whirlpools:
		apply_whirlpool_forces(w)
