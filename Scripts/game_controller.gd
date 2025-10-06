extends Node

@onready var altar = get_tree().get_first_node_in_group("altar")

func _ready():
	var altar = get_tree().get_first_node_in_group("altar")
	if altar:
		altar.connect("altar_depleted", Callable(self, "_on_altar_depleted"))

func on_altar_depleted():
	print("The altar's energy has been depleted. Game Over!")
	get_tree().reload_current_scene()
