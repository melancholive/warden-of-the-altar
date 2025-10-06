# spiral_shooter.gd
extends "res://Scripts/enemy.gd"

@export var bullets_per_shot: int = 4      # one bullet per cardinal direction
@export var rotate_angle: float = 25.0     # degrees to rotate after each shot
@export var shoot_interval: float = 1.0    # seconds between shots

var current_rotation: float = 0.0          # degrees

func _ready() -> void:
	max_health = 30  # 3 hits
	speed = 120.0
	super._ready()
	
func _physics_process(delta: float) -> void:
	move_behavior(delta)
	handle_shooting(delta)

func handle_shooting(delta: float) -> void:
	if not shoot_bullet or bullet_scene == null:
		return

	shoot_timer -= delta
	if shoot_timer <= 0:
		fire_spiral()
		current_rotation += rotate_angle
		shoot_timer = shoot_interval

func fire_spiral() -> void:
	for i in range(bullets_per_shot):
		var angle = deg_to_rad(i * 90 + current_rotation)
		var dir = Vector2.RIGHT.rotated(angle)
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = dir
		bullet.shooter = self
		bullet.spawn_position = global_position
		get_tree().current_scene.add_child(bullet)

	#print("[DEBUG] Enemy fired spiral bullets at rotation ", current_rotation)
