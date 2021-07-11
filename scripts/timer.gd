extends Label

var time: float = 0

var player
var active = false

func _ready():
	text = format_time()
	player = get_node("../../player")
	pass



func _process(delta):
	active = is_instance_valid(player) && !levels.loading
	active = active && player.started

	if !active:
		return

	time += delta
	text = format_time()

	
func format_time():
	var mins = int(time) / 60
	var secs = int(time) - mins * 60
	var millis = int((time - int(time)) * 60)

	return "\n %02d : %02d : %02d" % [mins, secs, millis]
