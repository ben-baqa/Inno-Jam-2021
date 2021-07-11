extends HSlider


func _ready():
	self.connect("value_changed", self, "adjust_volume")

func adjust_volume(val:float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), val)
