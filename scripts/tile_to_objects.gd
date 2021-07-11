extends Node2D

export(Array, String)var tile_names = []
export(Array, PackedScene)var objects = []

var map:TileMap


func _ready():
	map = get_node("../map grid")
	for i in range(0, objects.size()):
		replace_with(tile_names[i], objects[i])

func replace_with(name, obj):
	var tile_id = map.tile_set.find_tile_by_name(name)
	var cells = map.get_used_cells_by_id(tile_id)

	for v in cells:
		var rot = getRotation(map.is_cell_x_flipped(v.x, v.y), map.is_cell_y_flipped(v.x, v.y), map.is_cell_transposed(v.x, v.y))
		var inst = obj.instance()
		inst.global_position = map.map_to_world(v) + map.cell_size/ 2
		inst.rotate(rot[0])
		# inst.scale.y = rot[1];
		add_child(inst)

		map.set_cellv(v, -1)

#returns array of [angle,yflip]
static func getRotation(xflip, yflip, transpose)->Array:
	var y = 1
	if yflip:
		y = -1

	if (!xflip and !transpose):
		return [0.0, y]
	elif(xflip  and !transpose ):
		return [PI, y]
	elif(!xflip and transpose):
		return [-PI/2, y]
	elif(xflip and transpose):
		return [PI/2, y]
	return [0, 1]
