extends RigidBody2D

onready var whirlpools = get_parent().get_node("Whirlpools").get_children()
const FORCE = 500
const MAX_SPEED = 800
const WHIRL_RADIUS = 100
const MAX_RADIUS = 400
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
			w.s.frame = 1 if w.s.frame == 0 else 0
		if e.scancode == KEY_R:
			respawn()
		if e.scancode == KEY_ESCAPE:
			get_tree().quit()

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
	var target_velocity = v
	show_r = r
	
	if r.length() > MAX_RADIUS:
		linear_velocity = lerp(v.length(),0,0.01)*v.normalized()
		rotation_degrees = linear_velocity.angle() * 360 / (2*PI) + 90
		show_r = r
		return
	
	#Movement
	if w.s.frame == 0:
		var direction = 1 if r.cross(v) >= 0 else -1
		var dist = r.length()-WHIRL_RADIUS
		var tangent_direction = r.normalized().rotated(direction*PI/2)
		target_velocity = 300*tangent_direction + 300*lerp(0,dist,0.01) * r.normalized()
	else:
		target_velocity -= 10*FORCE/r.length()*r.normalized()
	target_velocity = clamp(target_velocity.length(),0,MAX_SPEED)*target_velocity.normalized()
	linear_velocity = lerp(v, target_velocity, 0.05)
	
	#Point forward
	rotation_degrees = linear_velocity.angle() * 360 / (2*PI) + 90

func respawn():
	reset_state = true

#Need to use this function to directly move boat at respawn (because it is a rigidbody)
func _integrate_forces(state):
	if reset_state:
		state.transform = Transform2D(0,respawn_position)
		linear_velocity = Vector2()
		reset_state = false

#NOT USING this, takes into account ALL the whirlpools
func all_whirlpool_forces():
	for w in whirlpools:
		apply_whirlpool_forces(w)

func _on_CloseButton_pressed():
	get_tree().quit()
