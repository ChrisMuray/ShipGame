extends RigidBody2D

const MAX_SPEED = 2000
onready var whirlpools = get_parent().get_node("Whirlpools").get_children()
onready var environment = get_parent().get_node("Environment")
onready var cam = get_node("Camera2D")
onready var respawn_position = position

export var enable_minimap: bool = false
export var enable_camera_follow: bool = true

var reset_state = false
var w
var dist

func _ready():
	cam.current = enable_camera_follow
	$Camera2D/GUI/MiniMap.visible = enable_minimap
	connect("body_entered", self, "_on_Boat_body_entered")
	set_camera_limits()

func set_camera_limits():
	var sand_tm = environment.get_node("Sand")
	var map_limits = sand_tm.get_used_rect()
	var map_cellsize = sand_tm.cell_size
	cam.limit_left = map_limits.position.x * map_cellsize.x
	cam.limit_right = map_limits.end.x * map_cellsize.x
	cam.limit_top = map_limits.position.y * map_cellsize.y
	cam.limit_bottom = map_limits.end.y * map_cellsize.y

func _input(e):
	if e is InputEventKey and e.pressed:
		if e.scancode == KEY_SPACE:
			if w and dist <= w.MAX_RADIUS:
				w.flip_state()
		if e.scancode == KEY_R:
			respawn()
		if e.scancode == KEY_ESCAPE:
			get_tree().quit()
		if e.scancode == KEY_C:
			var screenshot = get_viewport().get_texture().get_data()
			screenshot.flip_y()
			screenshot.save_png("res://Screengrab.png")

func _physics_process(delta):
	w = find_closest_whirlpool()
	dist = (position - w.position).length()
	if w and dist <= w.MAX_RADIUS:
		w.apply_whirlpool_forces()
	else:
		linear_velocity = lerp(linear_velocity.length(),0,0.01)*linear_velocity.normalized()
		rotation_degrees = linear_velocity.angle() * 360 / (2*PI)
	linear_velocity = clamp(linear_velocity.length(),0,MAX_SPEED) * linear_velocity.normalized()
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

func respawn():
	reset_state = true
	for w in whirlpools:
		w.set_state(w.PULL)

#Need to use this function to directly move boat at respawn (because it is a rigidbody)
func _integrate_forces(state):
	if reset_state:
		state.transform = Transform2D(0,respawn_position)
		linear_velocity = Vector2()
		reset_state = false

func _on_CloseButton_pressed():
	get_tree().quit()


func _on_Boat_body_entered(body):
	print(body)
	if body.is_in_group("goal"):
		Global.next_level()
