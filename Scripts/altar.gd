extends Area2D

@onready var collision = $CollisionShape2D

func _draw() -> void:
	draw_circle(Vector2.ZERO, collision.shape.radius, Color(0.0, 0.646, 0.22, 0.1))

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.in_altar_zone = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.in_altar_zone = false
