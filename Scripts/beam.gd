# beam.gd
extends Node2D
class_name BeamRay

@export var length: float = 800.0
@export var thickness: float = 6.0
@export var damage_per_second: float = 6.0
@export var track_target: bool = true

var shooter: Node = null
var _damage_accumulators := {}         # dictionary: target_id -> accumulated_float_seconds_damage
@onready var ray: RayCast2D = $RayCast2D
@onready var beam_line: Line2D = $BeamLine2D

func _ready() -> void:
	add_to_group("beam")
	ray.enabled = true
	_update_ray_and_visual()

func _process(delta: float) -> void:
	# If tracking, keep orientation updated externally by enemy (enemy can call look_at); but ensure ray points forward.
	_update_ray_and_visual()
	_apply_damage_along_ray(delta)

func _update_ray_and_visual() -> void:
	# Ray is local, cast_to should be in local coordinates
	ray.cast_to = Vector2(length, 0).rotated(rotation)
	ray.global_rotation = global_rotation
	# Update Line2D to show beam (from origin to hit point or full length)
	var end_point = Vector2(length, 0).rotated(rotation)
	if ray.is_colliding():
		var col_point = ray.get_collision_point()
		end_point = to_local(col_point)
	beam_line.clear_points()
	beam_line.width = thickness
	beam_line.add_point(Vector2.ZERO)
	beam_line.add_point(end_point)

func _apply_damage_along_ray(delta: float) -> void:
	# If the ray hits something, apply DPS to the player if hit
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and is_instance_valid(collider):
			# only damage player (or other damageable nodes)
			if collider.is_in_group("player") and collider.has_method("take_damage"):
				# accumulate fractional damage and only send integer damage when >=1
				var id = collider.get_instance_id()
				if not _damage_accumulators.has(id):
					_damage_accumulators[id] = 0.0
				_damage_accumulators[id] += damage_per_second * delta
				var to_apply = int(floor(_damage_accumulators[id]))
				if to_apply > 0:
					collider.take_damage(to_apply)
					_damage_accumulators[id] -= float(to_apply)
			# if beam can hit other targets, add logic here (enemies etc.)
	# clear accumulators for objects no longer hit
	var keys = _damage_accumulators.keys()
	for k in keys:
		var still_hit := false
		# check if current collider has this id; simpler: if ray collider id != k then clear
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider and collider.get_instance_id() == k:
				still_hit = true
		if not still_hit:
			_damage_accumulators.erase(k)

func _exit_tree() -> void:
	_damage_accumulators.clear()
