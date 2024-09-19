class_name Flamethrower
extends Node2D

@onready var animated_sprite_2d := $AnimatedSprite2D as AnimatedSprite2D
@onready var cooldown: Timer = $Cooldown
@onready var point_light_2d: PointLight2D = $PointLight2D

signal hit_flame

func _on_player_finder_body_entered(_body: PlayableCharacter) -> void:
	#animated_sprite_2d.speed_scale = 1
	#animated_sprite_2d.sprite_frames.set_animation_loop("on", true)
	animated_sprite_2d.play("on")
	point_light_2d.visible = true

func _on_player_finder_body_exited(_body: PlayableCharacter) -> void:
	#animated_sprite_2d.speed_scale = 0.5
	#animated_sprite_2d.sprite_frames.set_animation_loop("on", false)
	#animated_sprite_2d.play_backwards("on")
	#await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("off")
	point_light_2d.visible = false

func _on_area_2d_body_entered(_body: PlayableCharacter) -> void:
	hit_flame.emit()
