extends Node2D

onready var s = get_node("AnimatedSprite")
onready var boat = get_parent().get_parent().get_node("Boat")

const PULL = true
const PUSH = false

export var FORCE = 700
export var WHIRL_RADIUS = 150
export var MAX_RADIUS = 400

export var state = PULL

func _ready():
	set_state(state)

func _process(delta):
	pass

func set_state(state):
	self.state = state
	if state == PULL:
		s.play("pull")
	elif state == PUSH:
		s.play("push")

func flip_state():
	set_state(not state)

func get_state():
	return state

func apply_whirlpool_forces():
	var r = boat.position - position
	var v = boat.linear_velocity
	var target_velocity = v
	#Movement
	if state == PULL:
		var direction = 1 if r.cross(v) >= 0 else -1
		s.flip_v = bool((direction+1)/2)
		var l = 0.01
		var dist = r.length()-WHIRL_RADIUS
		var tangent_direction = r.normalized().rotated(direction*PI/2)
		target_velocity = FORCE*tangent_direction - FORCE*lerp(0,dist,l)*r.normalized()
	elif state == PUSH:
		target_velocity += 100*FORCE/r.length()*r.normalized()
	boat.linear_velocity = lerp(v, target_velocity, 0.05)
	
	#Point forward
	boat.rotation_degrees = boat.linear_velocity.angle() * 360 / (2*PI)
