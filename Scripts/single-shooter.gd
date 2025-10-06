extends "res://Scripts/enemy.gd"

func _ready() -> void:
	max_health = 20  # 2 hits (if player deals ~10 dmg per hit)
	speed = 100.0
	super._ready()

func fire_bullet_pattern():
	var player = get_tree().get_first_node_in_group("player")
	if player and bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = (player.global_position - global_position).normalized()
		get_tree().current_scene.add_child(bullet)
