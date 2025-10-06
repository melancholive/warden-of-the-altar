extends Area2D

@export var speed: float = 600.0
@export var damage: int = 5
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

	# Remove bullet if it leaves the viewport
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
