extends Camera2D

@export var player: Node2D

func _process(delta):
	if player:
		global_position = player.global_position
