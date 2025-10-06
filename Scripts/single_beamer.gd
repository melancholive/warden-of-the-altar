extends "res://Scripts/enemy.gd"

@onready var player = get_tree().get_first_node_in_group("player")
@onready var beam = $RayCast2D
@onready var beam_line = $Line2D
@onready var warning_line = $WarningLine2D  # Add a Line2D node for the warning

@export var beam_duration: float = 2.0
@export var beam_cooldown: float = 4.0
@export var warning_time: float = 1.0  # Time to show indicator before beam
@export var beam_speed: float = 2.0    # How fast the beam moves toward player

var state: String = "cooldown"  # "cooldown", "warning", "firing"
var timer: float = 0.0
var current_dir: Vector2 = Vector2.RIGHT

func _ready() -> void:
	max_health = 30  # 3 hits
	speed = 75.0
	super._ready()
	
func _process(delta):
	if not player:
		return

	timer += delta

	match state:
		"cooldown":
			if timer >= beam_cooldown:
				start_warning()
		"warning":
			update_warning()
			if timer >= warning_time:
				start_beam_attack()
		"firing":
			fire_beam(delta)

func start_warning():
	state = "warning"
	timer = 0.0
	current_dir = (player.global_position - global_position).normalized()
	if warning_line:
		warning_line.visible = true
		warning_line.points = [Vector2.ZERO, current_dir * 400]

func update_warning():
	if not warning_line:
		return
	# Slowly update warning line toward player
	var target_dir = (player.global_position - global_position).normalized()
	current_dir = current_dir.lerp(target_dir, beam_speed * get_process_delta_time())
	warning_line.points = [Vector2.ZERO, current_dir * 400]

func start_beam_attack():
	state = "firing"
	timer = 0.0
	if beam:
		beam.enabled = true
		beam.force_raycast_update()
	if beam_line:
		beam_line.visible = true
	if warning_line:
		warning_line.visible = false

func fire_beam(delta):
	# Slowly move beam toward player
	var target_dir = (player.global_position - global_position).normalized()
	current_dir = current_dir.lerp(target_dir, beam_speed * delta)

	# Update beam RayCast2D and Line2D
	if beam:
		beam.target_position = current_dir * 400
		beam.force_raycast_update()
	if beam_line:
		beam_line.points = [Vector2.ZERO, current_dir * 400]

	# Deal damage if colliding
	if beam.is_colliding():
		var collider = beam.get_collider()
		if collider and collider.is_in_group("player"):
			collider.take_damage(1)

	# End firing after duration
	if timer >= beam_duration:
		end_beam_attack()

func end_beam_attack():
	state = "cooldown"
	timer = 0.0
	if beam:
		beam.enabled = false
	if beam_line:
		beam_line.visible = false
