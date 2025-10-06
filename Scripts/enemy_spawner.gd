extends Node2D

@export var spawn_interval: float = 2.0
@export var min_spawn_interval: float = 0.5  # Hard limit for spawn interval
@export var max_enemies: int = 10
@export var enemy_scenes: Array[PackedScene] = []  # Order: Single, Spiral, Fan
@export var difficulty_scale_rate: float = 0.01  # How fast difficulty increases per second

var spawn_timer: float = 0.0
var enemies_alive: int = 0
var difficulty_timer: float = 0.0
var global_difficulty: float = 0.0

func _physics_process(delta: float) -> void:
	# Increase difficulty gradually over time
	global_difficulty += difficulty_scale_rate * delta

	# Handle spawning enemies
	spawn_timer -= delta
	if spawn_timer <= 0:
		if enemies_alive < max_enemies:
			spawn_enemy()
		spawn_timer = max(spawn_interval - global_difficulty, min_spawn_interval)  # Faster spawn as difficulty increases

func spawn_enemy():
	if enemy_scenes.size() == 0:
		print("[DEBUG] No enemy scenes assigned!")
		return

	var enemy_scene = choose_enemy()
	if enemy_scene == null:
		return

	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var cam_rect = Rect2(
		camera.global_position - camera.zoom * camera.get_viewport_rect().size / 2,
		camera.get_viewport_rect().size
	)

	var spawn_width = cam_rect.size.x * 4
	var spawn_height = cam_rect.size.y * 4
	var spawn_origin = cam_rect.position - Vector2(spawn_width / 2, spawn_height / 2)
	var spawn_pos = spawn_origin + Vector2(randf() * spawn_width, randf() * spawn_height)

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = spawn_pos
	enemy_instance.add_to_group("enemy")

	# Assign bullet scene and scale bullet counts based on submitted EXP + global difficulty
	if "shoot_bullet" in enemy_instance and "bullet_scene" in enemy_instance:
		var player = get_tree().get_first_node_in_group("player")
		var submitted_exp = 0
		if player:
			submitted_exp = player.submitted_exp

		enemy_instance.shoot_bullet = true
		enemy_instance.bullet_scene = preload("res://Scenes/bullet.tscn")

		# Scale bullets for fan/spiral enemies
		if "fan_bullets" in enemy_instance:
			enemy_instance.fan_bullets = 5 + int(submitted_exp / 20) + int(global_difficulty)
		if "spiral_bullets" in enemy_instance:
			enemy_instance.spiral_bullets = 3 + int(submitted_exp / 30) + int(global_difficulty)

	# Scale HP for enemies
	if "enemy_type" in enemy_instance:
		match enemy_instance.enemy_type:
			"single":
				enemy_instance.max_health = 10 + int(global_difficulty * 2)
			"spiral":
				enemy_instance.max_health = 15 + int(global_difficulty * 3)
			"fan":
				enemy_instance.max_health = 20 + int(global_difficulty * 4)
		enemy_instance.current_health = enemy_instance.max_health
		if enemy_instance.health_bar:
			enemy_instance.health_bar.max_value = enemy_instance.max_health
			enemy_instance.health_bar.value = enemy_instance.current_health

	# Add to scene
	var enemies_node = get_tree().current_scene.get_node_or_null("Enemies")
	if enemies_node:
		enemies_node.add_child(enemy_instance)
	else:
		get_tree().current_scene.add_child(enemy_instance)

	enemies_alive += 1
	print("[DEBUG] Spawned enemy: ", enemy_scene.resource_path, " at ", spawn_pos)
	enemy_instance.connect("tree_exited", Callable(self, "_on_enemy_removed"))

func choose_enemy() -> PackedScene:
	var player = get_tree().get_first_node_in_group("player")
	var submitted = 0
	if player:
		submitted = player.submitted_exp

	# Base ratios at game start: Single 80%, Spiral 15%, Fan 5%
	var base_ratios = [80.0, 15.0, 5.0]
	var max_ratio_shift = 50.0  # Maximum amount to redistribute from Single to Spiral/Fan

	# Calculate difficulty factor (0 -> start, 1 -> fully balanced)
	var difficulty_factor = clamp(global_difficulty / 100.0, 0.0, 1.0)  # Adjust 100.0 to control speed

	# Shift ratios over time
	var single_ratio = base_ratios[0] - max_ratio_shift * difficulty_factor
	var spiral_ratio = base_ratios[1] + (max_ratio_shift * 0.6) * difficulty_factor
	var fan_ratio = base_ratios[2] + (max_ratio_shift * 0.4) * difficulty_factor

	var weights = [single_ratio, spiral_ratio, fan_ratio]

	# Manually sum weights
	var total = 0.0
	for w in weights:
		total += w

	var roll = randf() * total
	var cumulative = 0.0
	for i in range(weights.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			return enemy_scenes[i]

	return enemy_scenes[0]


func _on_enemy_removed():
	enemies_alive = max(enemies_alive - 1, 0)
	print("[DEBUG] Enemy removed, enemies_alive = ", enemies_alive)
