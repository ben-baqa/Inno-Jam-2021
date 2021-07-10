extends Area2D


func _ready():
	pass


func _on_chaser_area_entered(area):
	print("oof this is bad")
	if(area.is_in_group("player")):
		print("oof this is bad")
	queue_free()