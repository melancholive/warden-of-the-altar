extends Node

@onready var altar = get_tree().get_first_node_in_group("altar")

# Ground EXP spawner properties
@export var random_exp_scene: PackedScene = preload("res://Scenes/ExpOrb.tscn")
@export var spawn_interval: float = 5.0
@export var min_value: int = 5
@export var max_value: int = 10

var exp_timer: float = 0.0

func _ready():
	# Connect altar depleted signal
	if altar:
		altar.connect("altar_depleted", Callable(self, "_on_altar_depleted"))

func _physics_process(delta: float) -> void:
	# Handle ground EXP spawning
	exp_timer -= delta
	if exp_timer <= 0:
		spawn_random_exp()
		exp_timer = spawn_interval

func spawn_random_exp() -> void:
	if random_exp_scene == null:
		print("[DEBUG] No EXP scene assigned!")
		return

	var orb = random_exp_scene.instantiate()
	var rng = RandomNumberGenerator.new()

	# Random position in camera view
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var cam_rect = Rect2(
		camera.global_position - camera.zoom * camera.get_viewport_rect().size / 2,
		camera.get_viewport_rect().size
	)

	var pos = cam_rect.position + Vector2(rng.randf() * cam_rect.size.x, rng.randf() * cam_rect.size.y)
	orb.global_position = pos
	orb.value = rng.randi_range(min_value, max_value)

	get_tree().current_scene.add_child(orb)
	print("[DEBUG] Spawned ground EXP at ", pos, " value: ", orb.value)

func _on_altar_depleted():
	print("The altar's energy has been depleted. Game Over!")
	get_tree().reload_current_scene()
