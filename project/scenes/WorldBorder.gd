extends Area2D

signal kill_player

func _ready():
	var player = self.get_node("../Player")
	# Connecting the signal from self to the player's method
	self.connect("kill_player", Callable(player, "_on_kill_player"))

func _on_body_entered(body):
	emit_signal("kill_player")
