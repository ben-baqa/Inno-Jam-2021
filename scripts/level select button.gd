extends Button

export var level_index: int = 0

func _ready():
	self.connect("pressed", self, "start_level")

func start_level(_garb = 0):
	levels.load_level(level_index)