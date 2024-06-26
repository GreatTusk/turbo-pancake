extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $Hitbox/CollisionShape2D

func _on_hitbox_body_entered(body):
	body.set_respawn_pos(Vector2(body.global_position.x, global_position.y))
	animated_sprite_2d.play("trigger")

#func _on_hitbox_body_entered(body: Player):
	#body.set_respawn_pos(Vector2(body.position.x, position.y))
	#animated_sprite_2d.play("trigger")
	
func _on_animated_sprite_2d_animation_finished():
	collision_shape_2d.disabled = true
	animated_sprite_2d.play("idle")
