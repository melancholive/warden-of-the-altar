# spiral_shooter.gd
extends "res://Scripts/enemy.gd"

@export var spiral_speed: float = 120.0
var spiral_angle: float = 0.0

func fire_bullet():
	spiral_angle += spiral_speed * get_process_delta_time()
	var angle_rad = deg_to_rad(spiral_angle)
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = Vector2.RIGHT.rotated(angle_rad)
	bullet.shooter = self
	bullet.spawn_position = global_position
	get_tree().current_scene.add_child(bullet)
	print("[DEBUG] Enemy fired spiral bullet at angle ", spiral_angle)
