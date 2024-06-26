extends Area2D

func _ready():
	var player = self.get_node("../Player")
	# Connecting the signal from self to the player's method
	self.connect("body_entered", Callable(player, "_on_world_border_entered"))

