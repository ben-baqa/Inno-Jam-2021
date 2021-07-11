extends Node2D

export(Array, PackedScene) var levels = []
export(Array, String) var level_names = []

var current_level_index:int = 0

var current_scene

var load_delay:float = 0
var load_timer: float = 0
var loading = false

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	pass

func _process(delta):
	if loading:
		load_timer += delta
		if load_timer > load_delay:
			current_scene.queue_free()
			current_scene = levels[current_level_index].instance()
			get_tree().get_root().add_child(current_scene)
			get_tree().set_current_scene(current_scene)
			loading = false



func reload_current_level(delay:float = 0):
	load_level(current_level_index, delay)

func load_next_level(delay:float = 0):
	load_level(current_level_index + 1, delay)

func load_level(n:int = 0, delay:float = 0):
	# print("attempting to load level %d" %[n])
	if loading:
		print("Error, already loading a level")
		return
	if n >= levels.size():
		print("Error, tried to load a level that does not exist")
		return

	current_level_index = n
	load_delay = delay
	load_timer = 0
	# current_scene.z_index = -100
	loading = true

func get_level_name(n: int):
	if n >= level_names.size():
		return "level: %d" %[n]
	return level_names[n]
