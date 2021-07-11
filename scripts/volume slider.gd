extends HSlider

export var hover_col: Color
export var normal_col: Color

var label

func _ready():
	self.connect("value_changed", self, "adjust_volume")
	label = get_node("../../label con/label")
	load_volume()

func _process(_delta):
	var col = normal_col
	if get_focus_owner() == self:
		col = hover_col
	label.add_color_override("font_color", col)


func adjust_volume(val:float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), val)


func load_volume():
	value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
