extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

signal hit_flame

func _ready():
	var player = self.get_node("../../Player")
	self.connect("hit_flame", Callable(player, "_on_kill_player"))

func _on_player_finder_body_entered(_body):
	animated_sprite_2d.play("on")

func _on_player_finder_body_exited(_body):
	animated_sprite_2d.play("off")

func _on_area_2d_body_entered(_body):
	emit_signal("hit_flame")
