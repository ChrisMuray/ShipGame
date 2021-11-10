extends RigidBody2D
var speed = 1000

onready var environment = get_parent().get_node("Environment")
onready var cam = get_node("Camera2D")

func _ready():
	set_camera_limits()

func _physics_process(delta):
	var v = Vector2()
	if Input.is_action_pressed("ui_right"):
		v.x += 1
	if Input.is_action_pressed("ui_left"):
		v.x -= 1
	if Input.is_action_pressed("ui_up"):
		v.y -= 1
	if Input.is_action_pressed("ui_down"):
		v.y += 1
	v = speed*v.normalized()
	linear_velocity = lerp(linear_velocity,v,0.5)
	rotation_degrees = linear_velocity.angle()*360/(2*PI)

func set_camera_limits():
	var sand_tm = environment.get_node("Sand")
	var map_limits = sand_tm.get_used_rect()
	var map_cellsize = sand_tm.cell_size
	cam.limit_left = map_limits.position.x * map_cellsize.x
	cam.limit_right = map_limits.end.x * map_cellsize.x
	cam.limit_top = map_limits.position.y * map_cellsize.y
	cam.limit_bottom = map_limits.end.y * map_cellsize.y
