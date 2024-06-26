extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

func _on_player_finder_body_entered(body):
	animated_sprite_2d.play("on")


func _on_player_finder_body_exited(body):
	animated_sprite_2d.play("off")

func _on_area_2d_body_entered(body):
	body.die()
#func _on_area_2d_body_entered(body: Player):
	#body.die()
