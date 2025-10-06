extends Area2D

@export var exp_amount: int = 5
signal collected(exp: int)

func _ready():
	add_to_group("exp_orb")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		emit_signal("collected", exp_amount)
		queue_free()
