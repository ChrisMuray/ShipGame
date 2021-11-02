extends Node2D

onready var s = get_node("AnimatedSprite")

func _ready():
	s.frame = 0

func _on_StaticBody2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		s.frame = 1 if s.frame == 0 else 0
