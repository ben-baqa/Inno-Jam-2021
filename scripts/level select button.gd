extends Button

export var level_index: int = 0

var desc

func _ready():
	self.connect("pressed", self, "start_level")
	desc = get_node("../../con/desc")

func _process(_delta):
	var col
	if is_hovered():
		col = theme.get_color("font_color_hover", "Button")
	else:
		col = theme.get_color("font_color", "Button")
	desc.add_color_override("font_color", col)


func start_level(_garb = 0):
	levels.load_level(level_index)

func set_level(n:int = 0):
	level_index = n
	text = str(n + 1)
	desc.text = levels.get_level_name(n)
