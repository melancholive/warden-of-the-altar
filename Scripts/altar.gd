extends Area2D

signal altar_depleted

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var progress_bar: TextureProgressBar = $PanelContainer/TextureProgressBar

@export var max_progress: float = 100.0
@export var current_progress: float = max_progress
@export var decay_rate: float = 2.0  # amount lost per second

func _ready() -> void:
	add_to_group("altar")
	progress_bar.max_value = max_progress
	progress_bar.value = current_progress
	
	# Connect signals to detect player
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta: float) -> void:
	update_progress(delta)

func update_progress(delta: float) -> void:
	current_progress = max(current_progress - decay_rate * delta, 0)
	progress_bar.value = current_progress

	if current_progress <= 0:
		emit_signal("altar_depleted")

func _on_body_entered(body):
	print("[DEBUG] Altar detected body: ", body.name)
	if body.is_in_group("player"):
		print("[DEBUG] Player entered altar zone")
		body.in_altar_zone = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		print("[DEBUG] Player left altar zone")
		body.in_altar_zone = false

func _draw() -> void:
	if collision and collision.shape:
		draw_circle(Vector2.ZERO, collision.shape.radius, Color(0.0, 0.646, 0.22, 0.1))
