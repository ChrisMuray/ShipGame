extends Node

var current_level = 0

func next_level():
	print("finished level:", current_level)
	current_level += 1
	set_level(current_level)

func set_level(level):
	get_tree().change_scene("res://Levels/Level" + str(level) + ".tscn")
	current_level = level
