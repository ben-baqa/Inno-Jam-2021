extends Line2D

export var disable_time: float

export var big_col: Color = Color.red
export var small_col: Color = Color.crimson
export var min_width: float = 1
export var max_width: float = 6
export var fluctuation_frequency:float = 1

var time_disabled = 0
var disabled = false

var max_length: float = 1000
var rot: float
var line_pts = [Vector2.ZERO, Vector2.ZERO]

var should_load:bool = true

func _ready():
	var buttons = get_tree().get_nodes_in_group("laser buttons")
	for b in buttons:
		b.connect("pushed", self, "disable")

	rot = rotation
	rotation = 0
	line_pts[0] = Vector2.DOWN.rotated(rot) * 8
	$contact.rotation = rot
	$emitter.rotation = rot
	cast_laser()

func _physics_process(_delta):
	if disabled:
		run_disabled()
	else:
		cast_laser()
		fluctuate()


func cast_laser():
	var dir = Vector2.UP.rotated(rot) * max_length
	var pos = global_position
	var space = get_world_2d().direct_space_state
	var cast = space.intersect_ray(pos, pos + dir)
	if cast:
		kill_body_if_player(cast.collider)

		line_pts[1] = cast.position - pos
		points = PoolVector2Array(line_pts)
		$contact.position = line_pts[1]

func kill_body_if_player(body):
	if(body.is_in_group("player")):
		if !should_load:
			return
		should_load = false

		var particles = get_node("../../death_particles")
		particles.global_position = body.global_position
		particles.emitting = true

		var sound = get_node("../../death_sound")
		sound.global_position = body.global_position
		sound.play()

		levels.reload_current_level(1.5)
		body.queue_free()
	pass

func fluctuate():
	var f = sin(OS.get_ticks_msec() * fluctuation_frequency / 100)
	f = (f + 1) / 2
	default_color = big_col.linear_interpolate(small_col, f)
	$contact.modulate = default_color
	width = lerp(min_width, max_width, f)

func run_disabled():
	if OS.get_ticks_msec() > time_disabled + disable_time * 1000:
		enable()

func disable():
	disabled = true
	default_color = Color.transparent
	$contact.visible = false
	time_disabled = OS.get_ticks_msec()

func enable():
	disabled = false
	default_color = big_col
	$contact.visible = true
