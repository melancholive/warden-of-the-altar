# fan_shooter.gd
extends "res://Scripts/enemy.gd"

@export var fan_bullets: int = 5
@export var fan_spread: float = 45.0  # degrees
@export var burst_count: int = 3       # bullets per burst
@export var burst_interval: float = 0.1
var burst_timer: float = 0.0
var bullets_fired_in_burst: int = 0
var firing_burst: bool = false

func _physics_process(delta: float) -> void:
	move_behavior(delta)
	handle_burst(delta)

func handle_burst(delta: float) -> void:
	if not shoot_bullet or bullet_scene == null:
		return

	if firing_burst:
		burst_timer -= delta
		if burst_timer <= 0 and bullets_fired_in_burst < burst_count:
			fire_fan_bullets()
			bullets_fired_in_burst += 1
			burst_timer = burst_interval
		elif bullets_fired_in_burst >= burst_count:
			firing_burst = false
			bullets_fired_in_burst = 0
			shoot_timer = shoot_cooldown
	else:
		shoot_timer -= delta
		if shoot_timer <= 0:
			firing_burst = true
			bullets_fired_in_burst = 0
			burst_timer = 0

func fire_fan_bullets():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	# Calculate base direction toward player
	var base_dir = (player.global_position - global_position).normalized()

	for i in range(fan_bullets):
		var angle_offset = deg_to_rad(-fan_spread/2 + i * (fan_spread/(fan_bullets-1)))
		var dir = base_dir.rotated(angle_offset)
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = dir
		bullet.shooter = self
		bullet.spawn_position = global_position
		get_tree().current_scene.add_child(bullet)

	print("[DEBUG] Enemy fired fan bullets toward player")
