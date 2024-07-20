class_name EndCheckpoint
extends Node2D

@onready var collision_shape_2d := $Area2D/CollisionShape2D as CollisionShape2D
@onready var animated_sprite_2d := $AnimatedSprite2D as AnimatedSprite2D

signal level_finished
	
func _on_area_2d_body_entered(_body: PlayableCharacter) -> void:
	emit_signal("level_finished")
	animated_sprite_2d.play("idle")
	collision_shape_2d.call_deferred("set_disabled", true)
