extends Node2D

	
func _on_player_finder_body_entered(body):
	$AnimatedSprite2D.play("on")


func _on_player_finder_body_exited(body):
	$AnimatedSprite2D.play("off")


func _on_area_2d_body_entered(body: CharacterBody2D):
	body.die()
