# fan_shooter.gd
extends "res://Scripts/enemy.gd"

@export var fan_bullets: int = 5
@export var fan_spread: float = 45.0

func fire_bullet():
	for i in range(fan_bullets):
		var angle = deg_to_rad(-fan_spread/2 + i * (fan_spread/(fan_bullets-1)))
		var dir = Vector2.RIGHT.rotated(angle)
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = dir
		bullet.shooter = self
		bullet.spawn_position = global_position
		get_tree().current_scene.add_child(bullet)
	print("[DEBUG] Enemy fired fan bullets")
