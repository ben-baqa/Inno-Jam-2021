extends Area2D

signal pushed

func _ready():
	self.connect("body_entered", self, "body_entered")
	pass

func body_entered(body):
	emit_signal("pushed")