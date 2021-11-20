tool
extends Node2D

func _process(delta):
	update()

func _draw():
	if Engine.editor_hint:
		draw_arc(Vector2(0,0), owner.WHIRL_RADIUS, 0, 2*PI, 1000, Color.green)
		draw_arc(Vector2(0,0), owner.MAX_RADIUS, 0, 2*PI, 1000, Color.red)
