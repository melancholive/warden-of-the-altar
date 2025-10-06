# enemy_base.gd
extends CharacterBody2D

@export var max_health: int = 10
@export var speed: float = 10.0
@export var damage_on_contact: int = 1
@export var shoot_bullet: bool = false
@export var bullet_scene: PackedScene
@export var shoot_cooldown: float = 2.0

var current_health: int
var shoot_timer: float = 0.0

@onready var health_bar: TextureProgressBar = $PanelContainer/TextureProgressBar

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	print("[DEBUG] Enemy ready: ", self.name, " shoot_bullet=", shoot_bullet, " bullet_scene=", bullet_scene)

func _physics_process(delta: float) -> void:
	move_behavior(delta)
	handle_shooting(delta)

func move_behavior(_delta: float) -> void:
	# Move toward player if exists
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		velocity = Vector2.ZERO
	elif player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

func handle_shooting(delta: float) -> void:
	if not shoot_bullet or bullet_scene == null:
		return

	shoot_timer -= delta
	if shoot_timer <= 0:
		fire_bullet()  # Default single shot toward player
		shoot_timer = shoot_cooldown

func fire_bullet():
	if bullet_scene == null:
		print("[DEBUG] Cannot fire: bullet_scene is null")
		return

	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (get_tree().get_first_node_in_group("player").global_position - global_position).normalized()

	# assign shooter **before adding to the scene**
	bullet.shooter = self
	bullet.spawn_position = global_position

	get_tree().current_scene.add_child(bullet)
	print("[DEBUG] Bullet spawned at ", bullet.global_position, " by ", self.name)


func take_damage(amount: int) -> void:
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
	if current_health <= 0:
		die()

func die() -> void:
	print("[DEBUG] Enemy ", self.name, " died")
	queue_free()
