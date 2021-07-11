extends GridContainer

export var block:PackedScene

func _ready():
	for i in range(1, levels.levels.size()):
		var inst = block.instance()
		add_child(inst)
		inst = inst.get_child(0)
		inst.level_index = i
		inst.text = str(i + 1)
