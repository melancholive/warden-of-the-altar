class_name Bullet
extends Area2D

@export var speed: float = 300.0
@export var damage: int = 5
var direction: Vector2 = Vector2.RIGHT
var shooter: Node = null
var spawn_position: Vector2

func _ready() -> void:
	spawn_position = global_position

func _physics_process(delta: float) -> void:
	# Move bullet
	position += direction * speed * delta

	# Despawn if too far from spawn
	if position.distance_to(spawn_position) > 1000:
		queue_free()

	# Despawn if shooter no longer exists
	if shooter == null or not is_instance_valid(shooter):
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return  # Ignore the shooter itself

	# Damage player if shot by enemy
	if shooter.is_in_group("enemy") and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return

	# Damage enemy if shot by player
	if shooter.is_in_group("player") and body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return

	# Optional: destroy on hitting walls
	if body.is_in_group("wall"):
		queue_free()
