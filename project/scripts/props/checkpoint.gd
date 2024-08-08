class_name Checkpoint
extends Node2D

@onready var animated_sprite_2d := $AnimatedSprite2D as AnimatedSprite2D
@onready var collision_shape_2d := $Hitbox/CollisionShape2D as CollisionShape2D

signal checkpoint_reached

func _on_hitbox_body_entered(_body: PlayableCharacter) -> void:
	checkpoint_reached.emit()
	animated_sprite_2d.play(&"trigger")
	
func _on_animated_sprite_2d_animation_finished() -> void:
	collision_shape_2d.disabled = true
	animated_sprite_2d.play(&"idle")
