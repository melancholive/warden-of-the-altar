extends CharacterBody2D

@export var speed: float = 200.0
@onready var health_bar = $PanelContainer/TextureProgressBar
@export var max_health: int = 100
@export var current_health: int = max_health
@export var heal_rate: float = 5.0
#@onready var bullet_scene = preload("res://Scenes/bullet.tscn")

var in_altar_zone: bool = false
var shoot_cooldown: float = 0.25
var shoot_timer: float = 0.0

func _ready():
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO

	# movement input
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	update_health(delta)

func update_health(delta: float) -> void:
	if (in_altar_zone and current_health < max_health):
		current_health = min(current_health + delta * heal_rate, max_health)
	
	health_bar.value = current_health

func take_damage(amount: int):
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()

func die() -> void:
	queue_free()
	print("Player has died!")
