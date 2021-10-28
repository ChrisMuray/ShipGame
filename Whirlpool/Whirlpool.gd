extends AnimatedSprite

func _ready():
	frame = 0

func _on_StaticBody2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		frame = 1 if frame == 0 else 0
