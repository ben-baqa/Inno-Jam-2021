extends Area2D

export var reset_delay: = 2

var time_pushed = 0

signal pushed

func _ready():
	self.connect("body_entered", self, "body_entered")
	pass

func _process(_delta):
	if(OS.get_ticks_msec() > time_pushed + reset_delay * 1000):
		$sprite.frame = 0

func body_entered(body):
	emit_signal("pushed")
	$sfx.play()
	$sprite.frame = 1
	time_pushed = OS.get_ticks_msec()