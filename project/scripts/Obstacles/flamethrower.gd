extends Node2D

@onready var animated_sprite_2d := $AnimatedSprite2D as AnimatedSprite2D

signal hit_flame

func _on_player_finder_body_entered(_body: PlayableCharacter) -> void:
	animated_sprite_2d.play("on")

func _on_player_finder_body_exited(_body: PlayableCharacter) -> void:
	animated_sprite_2d.play("off")

func _on_area_2d_body_entered(_body: PlayableCharacter) -> void:
	emit_signal("hit_flame")
