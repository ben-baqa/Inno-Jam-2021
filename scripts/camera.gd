extends Camera2D

export var lerp_mod: Vector2 = Vector2(1, 2)
export var max_dist: Vector2 = Vector2(100, 60)

var player
var chaser

func _ready():
	player = get_node("../player")
	chaser = get_node("../chaser/area")

func _process(delta):
	if !player:
		return
	var pos = global_position
	var goal = player.global_position
	pos.x = lerp(pos.x, goal.x, lerp_mod.x * delta)
	pos.y = lerp(pos.y, goal.y, lerp_mod.y * delta)

	var dist = pos - goal
	dist.x = clamp(dist.x, -max_dist.x, max_dist.x)
	dist.y = clamp(dist.y, -max_dist.y, max_dist.y)

	global_position = goal + dist
