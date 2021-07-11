extends CanvasLayer

var un_but

func _ready():
	un_but = get_node("vbox/unpause")
	un_but.connect("pressed", self, "unpause")
	get_node("vbox/retry").connect("pressed", self, "retry")
	get_node("vbox/main menu").connect("pressed", self, "menu")
	get_node("vbox/quit").connect("pressed", self, "quit")
	unpause()

func _input(event):
	if event.is_action_pressed("ui_pause"):
		if get_tree().paused:
			unpause()
		else:
			pause()


func pause():
	if levels.in_menu:
		return

	for c in get_children():
		c.visible = true
	get_tree().paused = true
	un_but.grab_focus()

func unpause():
	for c in get_children():
		c.visible = false
	get_tree().paused = false

func retry():
	unpause()
	levels.reload_current_level()

func menu():
	unpause()
	levels.load_menu()

func quit():
	get_tree().quit()


func update_volume():
	var slider = get_node("vbox/Volume/VSplitContainer/CenterContainer2/volume slider")
	slider.load_volume()