extends Area2D

@export var exp_value: int = 5
@export var altar_restore: float = 3.0
@export var speed: float = 50.0  # optional magnet movement

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	# Optional: move toward player if close (like EXP magnets)
	var player = get_tree().get_first_node_in_group("Player")
	if player and global_position.distance_to(player.global_position) < 100:
		global_position = global_position.move_toward(player.global_position, speed * delta)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.exp += exp_value
		body.total_exp += exp_value

		# Restore altar progress
		for altar in get_tree().get_nodes_in_group("altar"):
			altar.current_progress = min(altar.max_progress, altar.current_progress + altar_restore)
			altar.progress_bar.value = altar.current_progress

		queue_free()
