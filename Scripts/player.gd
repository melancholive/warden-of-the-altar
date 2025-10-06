extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: int = 100
@export var current_health: int = max_health
@export var heal_rate: float = 5.0
@export var shoot_cooldown: float = 0.25

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $PanelContainer/TextureProgressBar
@onready var bullet_scene = preload("res://Scenes/bullet.tscn")

var last_direction: Vector2 = Vector2.RIGHT
var in_altar_zone: bool = false
var shoot_timer: float = 0.0

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO

	# Handle movement input
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Update facing direction only when moving
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()

	velocity = direction.normalized() * speed
	move_and_slide()

	update_health(delta)

	# Play movement/idle animations
	if direction != Vector2.ZERO:
		_play_walk_animation(direction)
	else:
		_play_idle_animation(last_direction)

	# Handle shooting
	shoot_timer -= delta
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot()
		shoot_timer = shoot_cooldown

func update_health(delta: float) -> void:
	if in_altar_zone and current_health < max_health:
		current_health = min(current_health + delta * heal_rate, max_health)
	health_bar.value = current_health

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = last_direction.normalized()
		get_tree().current_scene.add_child(bullet)

func _play_walk_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim.play("walk_right")
		else:
			anim.play("walk_left")
	else:
		if direction.y > 0:
			anim.play("walk_down")
		else:
			anim.play("walk_up")

func _play_idle_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		anim.play("idle_right" if direction.x > 0 else "idle_left")
	else:
		anim.play("idle_down" if direction.y > 0 else "idle_up")
