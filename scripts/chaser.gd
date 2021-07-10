extends "res://scripts/hazard.gd"

export var follow_delay: int
export var trail_segments: int
export var trail_piece: PackedScene
export var max_segment_distance: float = 8

export var disabled: bool = false

var trail = []
var trail_parent
var pieces = []
var player
var player_sprite
var sprite

var line: Line2D
var pre_line: Line2D

var trail_positions = []
var pre_positions = []

var timer: int = 0

func _ready():
	player = get_node("../../player")
	player_sprite = player.get_node("sprite")
	trail_parent = get_node("../trail")
	
	line = get_node("../trail/line")
	line.points = PoolVector2Array()

	pre_line = trail_parent.get_node("preemptive line")
	pre_line.points = PoolVector2Array()

	sprite = $sprite

func _physics_process(_delta):
	check_for_start()
	if disabled:
		return

	record_step()

	if timer > follow_delay:
		recall_step()
	else:
		timer += 1

	if trail.size() > trail_segments:
		trail.pop_front()
	if pieces.size() > trail_segments:
		var p = pieces.pop_front()
		if p:
			p.queue_free()



func record_step():
	if !player:
		return
	var entry = {}
	entry.position = player.global_position
	entry.flip_h = player_sprite.flip_h
	entry.frame = player_sprite.frame
	trail.append(entry)
	pre_positions.append(entry.position)
	pre_line.points = PoolVector2Array(pre_positions)

func recall_step():
	var entry = trail.pop_front()
	if !entry:
		return

	build_trail(entry.position)

	global_position = entry.position
	sprite.flip_h = entry.flip_h
	sprite.frame = entry.frame

func build_trail(pos):
	var block = place_collider(pos)
	pieces.append(block)
	pre_positions.pop_front()

	var dist = global_position.distance_to(pos) > max_segment_distance
	if pieces.size() > 0 and dist:
		place_collider(global_position.linear_interpolate(pos, .5), block)

	trail_positions.append(pos)
	if trail_positions.size() > trail_segments:
		trail_positions.pop_front()

	line.points = PoolVector2Array(trail_positions)

func place_collider(pos, parent = trail_parent):
	var inst = trail_piece.instance()
	inst.global_position = pos
	parent.add_child(inst)
	return inst

func check_for_start():
	if !player:
		return
	disabled = !player.started
