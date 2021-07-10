extends Node2D

export(Array, PackedScene) var levels = []
export var current_level_index:int = 0

var current_scene

var load_index: int = 0
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
			current_scene = levels[load_index].instance()
			get_tree().get_root().add_child(current_scene)
			get_tree().set_current_scene(current_scene)
			loading = false



func reload_current_level(delay:float = 0):
	load_level(current_level_index, delay)

func load_level(n:int = current_level_index, delay:float = 0):
	print("loading level %d with %f seconds of delay" %[n, delay])
	# call_deferred("_deferred_load_level()", n)
	if n >= levels.size():
		print("Error, tried to load a level that does not exist")
		return;

	load_index = n
	load_delay = delay
	load_timer = 0
	current_scene.z_index = -100
	loading = true
