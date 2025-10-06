extends CharacterBody2D

@export var max_health: int = 10
@export var speed: float = 50.0
@export var damage_on_contact: int = 1
@export var shoot_bullet: bool = false
@export var bullet_scene: PackedScene
@export var shoot_cooldown: float = 2.0
@export var exp_drop: int = 10  # Base EXP dropped

# Current stats
var current_health: int
var shoot_timer: float = 0.0

@onready var health_bar: TextureProgressBar = $PanelContainer/TextureProgressBar
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Add this line

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

	if anim_sprite:
		anim_sprite.play("idle")  # Start idle by default

	# Scale stats based on player's submitted EXP
	scale_stats()

func scale_stats() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var submitted_exp = 0
	if player:
		submitted_exp = player.submitted_exp

	# Scale health: +1 HP per 20 submitted EXP
	current_health = max_health + int(submitted_exp / 20)
	if health_bar:
		health_bar.max_value = current_health
		health_bar.value = current_health

func _physics_process(delta: float) -> void:
	move_behavior(delta)
	handle_shooting(delta)

func move_behavior(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		# Play movement animation if available
		if anim_sprite:
			if velocity.length() > 0.1:
				if not anim_sprite.is_playing() or anim_sprite.animation != "walking":
					anim_sprite.play("walking")
				anim_sprite.flip_h = velocity.x > 0  # flip sprite left/right
			else:
				if anim_sprite.animation != "idle":
					anim_sprite.play("idle")

func handle_shooting(delta: float) -> void:
	if not shoot_bullet or not bullet_scene:
		return

	shoot_timer -= delta
	if shoot_timer <= 0:
		fire_bullet()
		shoot_timer = shoot_cooldown

func fire_bullet() -> void:
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		bullet.direction = (player.global_position - global_position).normalized()
	bullet.global_position = global_position
	bullet.shooter = self
	bullet.spawn_position = global_position
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: int) -> void:
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
	if current_health <= 0:
		die()

func die() -> void:
	print("[DEBUG] Enemy ", name, " died")
	
	# Drop EXP
	var exp_orb = preload("res://Scenes/EXPorb.tscn").instantiate()
	exp_orb.global_position = global_position
	exp_orb.value = randi_range(10, 20)
	get_tree().current_scene.add_child(exp_orb)

	queue_free()
