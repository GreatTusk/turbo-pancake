extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $Hitbox/CollisionShape2D

signal respawn_player

func _ready():
	var player = self.get_node("../../Player")
	self.connect("respawn_player", Callable(player, "_on_checkpoint_triggered"))

func _on_hitbox_body_entered(body):
	emit_signal("respawn_player")
	animated_sprite_2d.play("trigger")
	
func _on_animated_sprite_2d_animation_finished():
	collision_shape_2d.disabled = true
	animated_sprite_2d.play("idle")
