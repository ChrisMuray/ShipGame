extends RigidBody2D
onready var boat = get_parent().get_parent().get_node("Boat")
onready var s = get_node("AnimatedSprite")
export var speed = 200

func _process(delta):
	var r =  boat.position - position
	linear_velocity = lerp(linear_velocity,speed*r.normalized(),0.03)
	rotation = r.angle()
	s.modulate = Color(1-s.frame,0,s.frame)
