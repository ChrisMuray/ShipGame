extends Node2D

onready var sand_tm = get_node("Sand")
onready var grass_tm = get_node("Grass")
onready var ocean_tm = get_node("Ocean")
onready var boat = get_parent().get_node("Boat")
onready var whirlpool = preload("res://Whirlpool/Whirlpool.tscn")
onready var whirlpools = get_parent().get_node("Whirlpools")

var threshold = 0.3;
var size = Vector2(300,300)
var noise
var minimap_img

func _ready():
	noise = make_noise(size)
	
	#Make the world!
	var sand = make_map(size, noise, threshold)
	sand = dilate(erode(sand))
	set_tiles(sand_tm, sand, Vector2())
	
	var sand_border = BitMap.new()
	sand_border.create(size+Vector2(4,4))
	sand_border.set_bit_rect(Rect2(Vector2(),size+Vector2(4,4)),true)
	sand_border.set_bit_rect(Rect2(Vector2(2,2),size),false)
	set_tiles(sand_tm, sand_border, Vector2(-2,-2))
	
	var grass = make_map(size, noise, threshold + 0.05)
	grass = dilate(erode(grass))
	set_tiles(grass_tm, grass, Vector2())
	
	var ocean = BitMap.new()
	ocean.create(size/3)
	ocean.set_bit_rect(Rect2(Vector2(),size),true)
	set_tiles(ocean_tm, ocean, Vector2())
	
	for i in range(40):
		var pos = Vector2(randf()*16*size.x, randf()*16*size.y)
		var tile_pos = pos/16
		while sand_tm.get_cellv(tile_pos) != -1:
			pos = sand_tm.get_cell_size().x*Vector2(randf()*size.x, randf()*size.y)
			tile_pos = pos/16
		create_whirlpool(pos)
	
	minimap_img = make_minimap(sand,grass)

func _process(delta):
	update_minimap()

func update_minimap():
	var boat_pos = boat.position / sand_tm.cell_size
	var current_map = minimap_img.duplicate()
	current_map.lock()
	for i in range(-3,3):
		for j in range(-3,3):
			current_map.set_pixel(boat_pos.x+i,boat_pos.y+j,Color.red)
	current_map.unlock()
	var minimap_texture = ImageTexture.new()
	minimap_texture.create_from_image(current_map)
	boat.get_node("Camera2D/GUI/MiniMap").texture = minimap_texture

func create_whirlpool(pos):
	var w = whirlpool.instance()
	whirlpools.add_child(w)
	w.position = pos

func sum(a):
	var sum = 0
	for i in a:
		sum += i
	return sum

func make_noise(size):
	var noise = OpenSimplexNoise.new()
	randomize()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 50
	noise.persistence = 0.8
	return noise

func make_map(size, noise, threshold):
	var bm = BitMap.new()
	bm.create(size)
	for x in range(size.x):
		for y in range(size.y):
			bm.set_bit(Vector2(x,y),noise.get_noise_2d(x,y) > threshold)
	return bm

func set_tiles(tm, bm, start):
	var size = bm.get_size()
	for x in range(size.x):
		for y in range(size.y):
			var pos = Vector2(x,y)
			if bm.get_bit(pos):
				tm.set_cellv(pos + start,0)
	tm.update_bitmask_region(start,start + size)

func bm2image(bm):
	var img = Image.new()
	var size = bm.get_size()
	img.create(size.x,size.y,false,Image.FORMAT_RGBA8)
	img.lock()
	for x in range(size.x):
		for y in range(size.y):
			var v = 255*int(bm.get_bit(Vector2(x,y)))
			img.set_pixel(x,y,Color(v,v,v))
	img.unlock()
	return img

func make_minimap(sand, grass):
	var img = Image.new()
	var size = sand.get_size()
	img.create(size.x+4,size.y+4,false,Image.FORMAT_RGB8)
	img.fill(Color.burlywood)
	img.lock()
	for x in range(size.x):
		for y in range(size.y):
			var v = int(sand.get_bit(Vector2(x,y))) + int(grass.get_bit(Vector2(x,y)))
			var c
			match v:
				0:
					c = Color.cornflower
				1:
					c = Color.burlywood
				2:
					c = Color.greenyellow
			img.set_pixel(x+2,y+2,c)
	img.unlock()
	return img

func erode(bm):
	var out = bm.duplicate()
	var size = bm.get_size()
	for x in range(1,size.x-1):
		for y in range(1,size.y-1):
			var pos = Vector2(x,y)
			if bm.get_bit(pos):
				var neighbors =[int(bm.get_bit(Vector2(x,y+1))),
								int(bm.get_bit(Vector2(x,y-1))),
								int(bm.get_bit(Vector2(x-1,y))),
								int(bm.get_bit(Vector2(x+1,y))),
								int(bm.get_bit(Vector2(x-1,y+1))),
								int(bm.get_bit(Vector2(x+1,y+1))),
								int(bm.get_bit(Vector2(x-1,y-1))),
								int(bm.get_bit(Vector2(x+1,y-1)))]
				if sum(neighbors) < 8:
					out.set_bit(pos,0)
	return out

func dilate(bm):
	var out = bm.duplicate()
	var size = bm.get_size()
	for x in range(1,size.x-1):
		for y in range(1,size.y-1):
			var pos = Vector2(x,y)
			if not bm.get_bit(pos):
				var neighbors =[int(bm.get_bit(Vector2(x,y+1))),
								int(bm.get_bit(Vector2(x,y-1))),
								int(bm.get_bit(Vector2(x-1,y))),
								int(bm.get_bit(Vector2(x+1,y))),
								int(bm.get_bit(Vector2(x-1,y+1))),
								int(bm.get_bit(Vector2(x+1,y+1))),
								int(bm.get_bit(Vector2(x-1,y-1))),
								int(bm.get_bit(Vector2(x+1,y-1)))]
				if sum(neighbors) > 0:
					out.set_bit(pos,1)
	return out

#func update_image(value):
#	print(value)
#	threshold = value
#	var map = make_map(size, noise, threshold)
#	var new_map = dilate(erode(map))
#	var texture = ImageTexture.new()
#	texture.create_from_image(bm2image(new_map))
#	before.texture = texture
