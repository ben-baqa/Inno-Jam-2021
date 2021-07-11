extends Button

export var level_index: int = 0

func _ready():
	self.connect("pressed", self, "start_level")

func start_level(_garb = 0):
	levels.load_level(level_index)

func set_level(n:int = 0):
	level_index = n
	text = str(n + 1)
	get_node("../../con/desc").text = levels.get_level_name(n)
