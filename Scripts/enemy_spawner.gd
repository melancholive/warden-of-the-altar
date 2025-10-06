extends Node2D

@export var spawn_interval: float = 2.0
@export var max_enemies: int = 10
@export var enemy_scenes: Array[PackedScene] = []  # Order: Single, Spiral, Fan

var spawn_timer: float = 0.0
var enemies_alive: int = 0

func _physics_process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0:
		if enemies_alive < max_enemies:
			spawn_enemy()
		spawn_timer = spawn_interval

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

	# Assign bullet scene and scale bullet counts based on submitted EXP
	if "shoot_bullet" in enemy_instance and "bullet_scene" in enemy_instance:
		var player = get_tree().get_first_node_in_group("player")
		var submitted_exp = 0
		if player:
			submitted_exp = player.submitted_exp

		enemy_instance.shoot_bullet = true
		enemy_instance.bullet_scene = preload("res://Scenes/bullet.tscn")

		# Scale bullets for fan/spiral enemies
		if "fan_bullets" in enemy_instance:
			enemy_instance.fan_bullets = 5 + int(submitted_exp / 20)
		if "spiral_bullets" in enemy_instance:
			enemy_instance.spiral_bullets = 3 + int(submitted_exp / 30)

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

	# Base probabilities (Single, Spiral, Fan)
	var weights = [50, 30 + submitted * 0.5, 20 + submitted * 0.5]

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
