extends Node2D

@export var spawn_interval: float = 2.0
@export var max_enemies: int = 10
@export var enemy_scenes: Array[PackedScene] = []

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

	var camera = get_viewport().get_camera_2d()
	if not camera:
		print("[DEBUG] No Camera2D found!")
		return

	var cam_rect = Rect2(
		camera.global_position - camera.zoom * camera.get_viewport_rect().size / 2,
		camera.get_viewport_rect().size
	)

	var spawn_width = cam_rect.size.x * 4
	var spawn_height = cam_rect.size.y * 4
	var spawn_origin = cam_rect.position - Vector2(spawn_width / 2, spawn_height / 2)
	var spawn_pos = spawn_origin + Vector2(randf() * spawn_width, randf() * spawn_height)

	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = spawn_pos
	enemy_instance.add_to_group("enemy")

	# Assign bullet scene
	if "shoot_bullet" in enemy_instance and "bullet_scene" in enemy_instance:
		enemy_instance.shoot_bullet = true
		enemy_instance.bullet_scene = preload("res://Scenes/bullet.tscn")

	# Add to scene
	var enemies_node = get_tree().current_scene.get_node_or_null("Enemies")
	if enemies_node:
		enemies_node.add_child(enemy_instance)
	else:
		get_tree().current_scene.add_child(enemy_instance)

	enemies_alive += 1
	print("[DEBUG] Spawned enemy: ", enemy_scene.resource_path, " at ", spawn_pos)
	enemy_instance.connect("tree_exited", Callable(self, "_on_enemy_removed"))

func _on_enemy_removed():
	enemies_alive = max(enemies_alive - 1, 0)
