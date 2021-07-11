extends Control

var main_menu
var level_select_menu

var play_button
var back_button

var foc = null

func _ready():
	play_button = get_node("main menu/Play/play_button")
	play_button.connect("pressed", self, "play")
	var level_button = get_node("main menu/Level Select/level_select_button")
	level_button.connect("pressed", self, "level_select")
	var quit_button = get_node("main menu/Quit/quit_button")
	quit_button.connect("pressed", self, "quit")

	back_button = get_node("level select menu/Back/button")
	back_button.connect("button_down", self, "return_to_main")

	main_menu = get_node("main menu")
	level_select_menu = get_node("level select menu")
	
	level_select_menu.visible = false
	main_menu.visible = true
	play_button.grab_focus()

	foc = get_focus_owner()


func _process(_delta):
	var new_foc = get_focus_owner()
	if new_foc != foc:
		$tick.play()
		foc = new_foc

func quit(_garb = 0):
	$select.play()
	get_tree().quit()

func play():
	$select.play()
	levels.reload_current_level()

func level_select(_garb = 0):
	level_select_menu.visible = true
	$ls_back.visible = true
	main_menu.visible = false
	back_button.grab_focus()
	$select.play()

func return_to_main(_garb = 0):
	level_select_menu.visible = false
	$ls_back.visible = false
	main_menu.visible = true
	play_button.grab_focus()
	$select.play()
