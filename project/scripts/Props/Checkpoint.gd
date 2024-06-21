extends Node2D

func _on_hitbox_body_entered(body):
	get_node("../../../Main").set_respawn_pos(Vector2(body.position.x, position.y))
	$AnimatedSprite2D.play("trigger")
	await $AnimatedSprite2D.animation_finished
	$Hitbox/CollisionShape2D.disabled = true
	$AnimatedSprite2D.play("idle")
	print("set pos ", position)
