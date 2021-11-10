extends Node2D

onready var boat = get_parent().get_node("Boat")
onready var whirlpools = get_parent().get_node("Whirlpools").get_children()

func _draw():
	var w = boat.find_closest_whirlpool()
	if w:
		var dist = (boat.position - w.position).length()
		if dist <= w.MAX_RADIUS:
			draw_arc(w.position, w.WHIRL_RADIUS, 0, 2*PI, 1000, Color.green)
			draw_arc(w.position, w.MAX_RADIUS, 0, 2*PI, 1000, Color.red)
			draw_line(w.position, boat.position, Color.red)
	pass

func _physics_process(delta):
	update()
