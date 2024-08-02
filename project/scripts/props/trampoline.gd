class_name Trampoline
extends Node2D

@onready var sprite := $Sprite as AnimatedSprite2D
@onready var bounce_sfx := $BounceSFX as AudioStreamPlayer

signal jumped_on

func _on_jump_hitbox_body_entered(_body: Node2D) -> void:
	sprite.play("launch")
	bounce_sfx.play()
	jumped_on.emit()
