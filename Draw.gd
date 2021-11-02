extends Node2D

onready var boat = get_parent().get_node("Boat")
onready var whirlpools = get_parent().get_node("Whirlpools").get_children()

func _draw():
	var r_color
	if boat.show_r.length() > 400:
		r_color = Color.blue
	else:
		r_color = Color.red
		#draw_line(boat.position, boat.position + 50*boat.show_tangent, Color(255,255,255))
		#draw_line(boat.position, boat.position + 50*boat.show_acc.normalized(), Color(0,255,0))
	draw_line(boat.position, boat.position + boat.show_r, r_color)
	
	for w in whirlpools:
		draw_arc(w.position, boat.WHIRL_RADIUS, 0, 2*PI, 1000, Color.green)
		draw_arc(w.position, boat.MAX_RADIUS, 0, 2*PI, 1000, Color.red)
		pass

func _physics_process(delta):
	update()
