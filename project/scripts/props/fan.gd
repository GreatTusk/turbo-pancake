class_name Fan
extends Node2D

@export var extra_reach_px: float = 0

@onready var sfx := $SFX/AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var air_particles := $AirParticles as GPUParticles2D
@onready var hitbox := $Area2D/Hitbox as CollisionShape2D

var own_index: int

signal fan_collided(rotation: float, index: int)
signal deactivated(index: int)

func _ready() -> void:
	
	if extra_reach_px != 0:
		hitbox.position.y -= extra_reach_px / 2.0
		var new_hitbox := RectangleShape2D.new()
		new_hitbox.size = Vector2(
			(hitbox.shape as RectangleShape2D).size.x, 
			(hitbox.shape as RectangleShape2D).size.y + extra_reach_px)
		hitbox.shape = new_hitbox

func _on_area_2d_body_entered(_body: Node2D) -> void:
	fan_collided.emit(self.rotation, own_index)

func _on_area_2d_body_exited(_body: Node2D) -> void:
	deactivated.emit(own_index)
