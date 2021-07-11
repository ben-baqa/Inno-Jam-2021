extends Area2D

var should_load:bool = true

func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	pass

func _on_body_entered(body):
	if(body.is_in_group("player")):
		if !should_load:
			return
		should_load = false

		$particles.global_position = body.global_position
		$particles.emitting = true

		levels.load_next_level(.75)