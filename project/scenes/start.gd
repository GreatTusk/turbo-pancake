extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $Area2D/CollisionShape2D

signal set_respawn_pos

func _ready():
	var player = self.get_node("../../Player")
	self.connect("set_respawn_pos", Callable(player, "_on_checkpoint_triggered"))

func _on_area_2d_body_entered(body):
	emit_signal("set_respawn_pos")
	animated_sprite_2d.play("idle")
	
func _on_animated_sprite_2d_animation_finished():
	collision_shape_2d.disabled = true
	

