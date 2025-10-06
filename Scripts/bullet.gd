extends Area2D

@export var speed: float = 600.0
@export var damage: int = 5
@export var max_distance: float = 800.0

var direction: Vector2 = Vector2.RIGHT
var shooter: Node = null
var spawn_position: Vector2

func _physics_process(delta: float) -> void:
	if shooter == null:
		return # wait until shooter is assigned

	position += direction * speed * delta

	# Despawn after traveling too far
	if spawn_position.distance_to(global_position) > max_distance:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if shooter == null:
		return

	var target_group = ""
	if shooter.is_in_group("player"):
		target_group = "enemy"
	elif shooter.is_in_group("enemy"):
		target_group = "player"

	if not body.is_in_group(target_group):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
		print("[DEBUG] Bullet from ", shooter.name, " hit ", body.name, " for ", damage, " damage")

	queue_free()
