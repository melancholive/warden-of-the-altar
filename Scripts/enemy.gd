extends CharacterBody2D

@export var max_health: int = 10
@export var speed: float = 100.0
@export var damage_on_contact: int = 1
@export var shoot_bullet: bool = false
@export var bullet_scene: PackedScene
@export var shoot_cooldown: float = 2.0
@export var exp_drop: int = 5

var current_health: int
var shoot_timer: float = 0.0

@onready var health_bar: TextureProgressBar = $PanelContainer/TextureProgressBar

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	print("[DEBUG] Enemy ready: ", self.name, " shoot_bullet=", shoot_bullet)

func _physics_process(delta: float) -> void:
	move_behavior(delta)
	handle_shooting(delta)

func move_behavior(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

func handle_shooting(delta: float) -> void:
	if not shoot_bullet or not bullet_scene:
		return

	shoot_timer -= delta
	if shoot_timer <= 0:
		fire_bullet()
		shoot_timer = shoot_cooldown

func fire_bullet():
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
	print("[DEBUG] Enemy ", self.name, " died")
	drop_exp()
	queue_free()

func drop_exp():
	var orb_scene = preload("res://Scenes/EXPorb.tscn")
	var orb = orb_scene.instantiate()
	orb.global_position = global_position
	orb.exp_amount = exp_drop
	var player = get_tree().get_first_node_in_group("player")
	if player:
		orb.connect("collected", Callable(player, "_on_exp_collected"))
	get_tree().current_scene.add_child(orb)
