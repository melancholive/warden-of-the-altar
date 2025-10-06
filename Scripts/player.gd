extends CharacterBody2D

@export var speed: float = 275.0
@export var max_health: int = 100
@export var heal_rate: float = 1.0
@export var shoot_cooldown: float = 0.15

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $PanelContainer/TextureProgressBar
@onready var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var collision: CollisionShape2D = $CollisionShape2D

var current_health: float
var last_direction: Vector2 = Vector2.RIGHT
var shoot_timer: float = 0.0
var in_altar_zone: bool = false
var collected_exp: int = 0
var submitted_exp: int = 0

	
func _ready() -> void:
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"): direction.x += 1
	if Input.is_action_pressed("ui_left"): direction.x -= 1
	if Input.is_action_pressed("ui_down"): direction.y += 1
	if Input.is_action_pressed("ui_up"): direction.y -= 1

	if direction != Vector2.ZERO:
		last_direction = direction.normalized()

	velocity = direction.normalized() * speed
	move_and_slide()

	update_health(delta)
	handle_shooting(delta)
	handle_altar_submission(delta)

	# Animations
	if direction != Vector2.ZERO:
		_play_walk_animation(direction)
	else:
		_play_idle_animation(last_direction)

func handle_shooting(delta: float) -> void:
	shoot_timer -= delta
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot()
		shoot_timer = shoot_cooldown

func shoot() -> void:
	if not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = last_direction.normalized()
	bullet.shooter = self
	bullet.spawn_position = global_position
	get_tree().current_scene.add_child(bullet)

func update_health(delta: float) -> void:
	if in_altar_zone and current_health < max_health:
		current_health = min(current_health + delta * heal_rate, max_health)
	health_bar.value = current_health

func handle_altar_submission(delta: float) -> void:
	if in_altar_zone and collected_exp > 0:
		# How much EXP is submitted per second
		var submit_rate: float = 10.0  # adjust as desired
		var exp_to_submit = min(submit_rate * delta, collected_exp)

		collected_exp -= exp_to_submit
		submitted_exp += exp_to_submit

		# Update the altar progress if needed
		var altar = get_tree().get_first_node_in_group("altar")
		if altar:
			altar.current_progress = min(altar.current_progress + exp_to_submit, altar.max_progress)
			if altar.progress_bar:
				altar.progress_bar.value = altar.current_progress

		print("[DEBUG] Submitting EXP: ", exp_to_submit, ", Remaining Collected: ", collected_exp)

func _on_exp_collected(exp: int) -> void:
	collected_exp += exp
	print("[DEBUG] Collected EXP: ", exp, ", Total Collected: ", collected_exp)

func take_damage(amount: int) -> void:
	current_health -= amount
	health_bar.value = current_health
	if current_health <= 0:
		die()

func die() -> void:
	print("[DEBUG] Player died")
	get_tree().call_deferred("reload_current_scene")
	queue_free()

# Animations
func _play_walk_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		anim.play("walk_right" if direction.x > 0 else "walk_left")
	else:
		anim.play("walk_down" if direction.y > 0 else "walk_up")

func _play_idle_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		anim.play("idle_right" if direction.x > 0 else "idle_left")
	else:
		anim.play("idle_down" if direction.y > 0 else "idle_up")
