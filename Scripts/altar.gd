extends Area2D

signal altar_depleted

@onready var collision = $CollisionShape2D
@onready var progress_bar = $PanelContainer/TextureProgressBar

@export var max_progress: float = 100.0
@export var current_progress: float = max_progress
@export var decay_rate: float = 2.0  # amount lost per second
@export var healing_rate: float = 15.0  # how much the altar heals the player per second

# Track players in altar zone
var players_in_zone: Array = []

func _ready():
	add_to_group("altar")
	progress_bar.value = current_progress

	# Connect signals for body enter/exit
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta: float) -> void:
	update_progress(delta)
	heal_players(delta)

func update_progress(delta: float) -> void:
	# Altar naturally decays
	current_progress = max(current_progress - decay_rate * delta, 0)
	progress_bar.value = current_progress

	if current_progress <= 0:
		emit_signal("altar_depleted")

func heal_players(delta: float) -> void:
	for player in players_in_zone:
		if is_instance_valid(player):
			if player.current_health < player.max_health:
				player.current_health = min(player.current_health + healing_rate * delta, player.max_health)
				if player.health_bar:
					player.health_bar.value = player.current_health
				#print("[DEBUG] Healing player ", player.name, " to ", player.current_health)

func _draw() -> void:
	if collision.shape:
		draw_circle(Vector2.ZERO, collision.shape.radius, Color(0.0, 0.646, 0.22, 0.1))

func _on_body_entered(body):
	if body.is_in_group("player") and not players_in_zone.has(body):
		players_in_zone.append(body)
		body.in_altar_zone = true

func _on_body_exited(body):
	if body.is_in_group("player") and players_in_zone.has(body):
		players_in_zone.erase(body)
		body.in_altar_zone = false
