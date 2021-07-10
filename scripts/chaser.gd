extends Area2D

export var follow_delay: int
export var trail_segments: int
export var trail_width: float
export var trail_piece: PackedScene

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
	record_step()

	if timer > trail_segments + follow_delay:
		recall_step()
	else:
		timer += 1

	if trail.size() > trail_segments:
		trail.pop_front()
	if pieces.size() > trail_segments:
		pieces.pop_front().queue_free()



func record_step():
	var entry = {}
	entry.position = player.global_position
	entry.tex = player_sprite.texture
	entry.flip_h = player_sprite.flip_h
	entry.vframes = player_sprite.vframes
	entry.hframes = player_sprite.hframes
	entry.frame = player_sprite.frame
	trail.append(entry)
	pre_positions.append(entry.position)
	pre_line.points = PoolVector2Array(pre_positions)

func recall_step():
	var entry = trail.pop_front()

	rebuild_trail_polys(entry.position)
	var inst = trail_piece.instance()
	inst.global_position = entry.position
	trail_parent.add_child(inst)
	pieces.append(inst)
	pre_positions.pop_front()

	global_position = entry.position
	sprite.texture = entry.tex
	sprite.flip_h = entry.flip_h
	sprite.vframes = entry.vframes
	sprite.hframes = entry.hframes
	sprite.frame = entry.frame

func rebuild_trail_polys(pos):

	trail_positions.append(pos)
	if trail_positions.size() > trail_segments:
		trail_positions.pop_front()

	line.points = PoolVector2Array(trail_positions)


func _on_area_body_entered(body):
	if(body.is_in_group("player")):
		print("oof this is bad")
