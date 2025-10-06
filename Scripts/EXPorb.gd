class_name ExpOrb
extends Area2D

@export var value: int = 10        # Base value
@export var pickup_radius: float = 16.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Smaller sprite for low-value EXP
	sprite.scale = Vector2(0.5, 0.5) if value < 10 else Vector2(1, 1)
	
	# Slight random offset for natural placement
	var rng = RandomNumberGenerator.new()
	position += Vector2(rng.randf_range(-16,16), rng.randf_range(-16,16))
	
	# Connect pickup signal
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("_on_exp_collected"):
		body._on_exp_collected(value)
		queue_free()
		#print("[DEBUG] Player picked up EXP: ", value)
