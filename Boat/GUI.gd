extends Node2D

onready var cam = get_parent()
onready var boat = cam.get_parent()
onready var offset = position

func _process(delta):
	set_global_position(cam.get_camera_screen_center() + offset)
	set_rotation(-boat.rotation)
