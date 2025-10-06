class_name Bullet
extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT
var shooter: Node = null
var spawn_position: Vector2

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	spawn_position = global_position
	update_color()
	connect("body_entered", Callable(self, "_on_body_entered"))

func update_color() -> void:
	if shooter == null:
		sprite.modulate = Color.WHITE
	elif shooter.is_in_group("enemy"):
		sprite.modulate = Color.RED
	elif shooter.is_in_group("player"):
		sprite.modulate = Color.WHITE

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	if position.distance_to(spawn_position) > 1000:
		queue_free()
	if shooter == null or not is_instance_valid(shooter):
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return

	# Player bullets hit enemies
	if shooter != null and shooter.is_in_group("player") and body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return

	# Enemy bullets hit player
	if shooter != null and shooter.is_in_group("enemy") and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return
