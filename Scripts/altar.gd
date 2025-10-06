extends Area2D

signal altar_depleted

@onready var collision = $CollisionShape2D
@onready var progress_bar = $PanelContainer/TextureProgressBar

@export var max_progress: float = 100.0
@export var current_progress: float = max_progress
@export var decay_rate: float = 2.0  # amount lost per second

func _ready():
	add_to_group("altar")
	progress_bar.value = current_progress

func _physics_process(delta: float) -> void:
	update_progress(delta)

func update_progress(delta: float) -> void:
	current_progress = max(current_progress - decay_rate * delta, 0)
	progress_bar.value = current_progress

	if current_progress <= 0:
		_on_altar_depleted()

func _on_altar_depleted():
	emit_signal("altar_depleted")

func _draw() -> void:
	draw_circle(Vector2.ZERO, collision.shape.radius, Color(0.0, 0.646, 0.22, 0.1))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.in_altar_zone = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.in_altar_zone = false
