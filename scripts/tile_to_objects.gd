extends TileMap

export(Array, String)var tile_names = []
export(Array, PackedScene)var objects = []


func _ready():
	for i in range(0, objects.size()):
		replace_with(tile_names[i], objects[i])

func replace_with(name, obj):
	var tile_id = tile_set.find_tile_by_name(name)
	var cells = get_used_cells_by_id(tile_id)

	for v in cells:
		var rot = getRotation(is_cell_x_flipped(v.x, v.y), is_cell_y_flipped(v.x, v.y), is_cell_transposed(v.x, v.y))
		var inst = obj.instance()
		inst.global_position = map_to_world(v) + cell_size/ 2
		inst.rotation = rot[0]
		inst.scale.y = rot[1];
		add_child(inst)

		set_cellv(v, -1)

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