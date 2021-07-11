extends Container

export var block:PackedScene

func _ready():
	for i in range(1, levels.levels.size()):
		var inst = block.instance()
		add_child(inst)
		var button = inst.get_child(0)
		while is_instance_valid(button) and button.name != "button":
			button = button.get_child(0)
		if button:
			button.set_level(i)
