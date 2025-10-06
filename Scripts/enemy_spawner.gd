extends Node2D

@export var spawn_interval: float = 2.0
@export var min_spawn_interval: float = 0.5
@export var max_enemies: int = 10
@export var enemy_scenes: Array[PackedScene] = []  # Order: Single, Spiral, Beamer, Fan
@export var difficulty_scale_rate: float = 0.01

var spawn_timer: float = 0.0
var enemies_alive: int = 0
var global_difficulty: float = 0.0

func _physics_process(delta: float) -> void:
	global_difficulty += difficulty_scale_rate * delta
	spawn_timer -= delta
	if spawn_timer <= 0:
		if enemies_alive < max_enemies:
			spawn_enemy()
		spawn_timer = max(spawn_interval - global_difficulty, min_spawn_interval)


func spawn_enemy():
	if enemy_scenes.size() == 0:
		print("[DEBUG] No enemy scenes assigned!")
		return

	var enemy_scene = choose_enemy()
	if enemy_scene == null:
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Spawn within a radius around the player
	var spawn_radius = 1000.0 + global_difficulty * 2  # enemies get slightly closer/further as difficulty increases
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	var spawn_pos = player.global_position + offset

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = spawn_pos
	enemy_instance.add_to_group("enemy")

	# Assign bullet scene if applicable
	if "shoot_bullet" in enemy_instance and "bullet_scene" in enemy_instance:
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

	# Scale HP
	if "enemy_type" in enemy_instance:
		match enemy_instance.enemy_type:
			"single":
				enemy_instance.max_health = 10 + int(global_difficulty * 2)
			"spiral":
				enemy_instance.max_health = 15 + int(global_difficulty * 3)
			"beamer":
				enemy_instance.max_health = 25 + int(global_difficulty * 5)
			"fan":
				enemy_instance.max_health = 20 + int(global_difficulty * 4)

		enemy_instance.current_health = enemy_instance.max_health
		if enemy_instance.health_bar:
			enemy_instance.health_bar.max_value = enemy_instance.max_health
			enemy_instance.health_bar.value = enemy_instance.current_health

	var enemies_node = get_tree().current_scene.get_node_or_null("Enemies")
	if enemies_node:
		enemies_node.add_child(enemy_instance)
	else:
		get_tree().current_scene.add_child(enemy_instance)

	enemies_alive += 1
	#print("[DEBUG] Spawned enemy: ", enemy_scene.resource_path, " at ", spawn_pos)
	enemy_instance.connect("tree_exited", Callable(self, "_on_enemy_removed"))


func choose_enemy() -> PackedScene:
	var player = get_tree().get_first_node_in_group("player")
	var submitted = 0
	if player:
		submitted = player.submitted_exp

	# Base ratios for easier enemies first
	# Order: Single, Spiral, Beamer, Fan
	var base_ratios = [70.0, 15.0, 10.0, 5.0]
	var max_ratio_shift = 40.0
	var difficulty_factor = clamp(global_difficulty / 100.0, 0.0, 1.0)
	print(global_difficulty)

	# Shift ratios gradually as difficulty increases
	var single_ratio = base_ratios[0] - max_ratio_shift * difficulty_factor
	var spiral_ratio = base_ratios[1] + (max_ratio_shift * 0.3) * difficulty_factor
	var beamer_ratio = base_ratios[2] + (max_ratio_shift * 0.4) * difficulty_factor
	var fan_ratio = base_ratios[3] + (max_ratio_shift * 0.3) * difficulty_factor

	# Only allow beam/fan enemies after a difficulty threshold
	var beam_threshold = 0.3  # adjust this value
	var fan_threshold = 0.5   # adjust this value
	if global_difficulty < beam_threshold:
		beamer_ratio = 0
	if global_difficulty < fan_threshold:
		fan_ratio = 0

	var weights = [single_ratio, spiral_ratio, beamer_ratio, fan_ratio]

	var total = 0.0
	for w in weights:
		total += max(w, 0.0)  # avoid negative weights

	var roll = randf() * total
	var cumulative = 0.0
	for i in range(weights.size()):
		cumulative += max(weights[i], 0.0)
		if roll <= cumulative:
			return enemy_scenes[i]

	return enemy_scenes[0]  # fallback



func _on_enemy_removed():
	enemies_alive = max(enemies_alive - 1, 0)
	print("[DEBUG] Enemy removed, enemies_alive = ", enemies_alive)
