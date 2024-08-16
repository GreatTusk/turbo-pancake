class_name Fan
extends Node2D

@export var extra_reach_px: float = 0

@onready var air_particles := $AirParticles as GPUParticles2D
@onready var hitbox := $Area2D/Hitbox as CollisionShape2D

var own_index: int

signal fan_collided(rotation: float, index: int)
signal deactivated(index: int)

func _ready() -> void:
	"""
	29px from gpuparticles to end of collision shape when lifetime is 1.0
	Amount 16 particles for 29px in 1.0 second
	"""
	
	if extra_reach_px != 0:
		const seconds_per_pixel: float = 1.0 / 29.0
		const particles_per_secons: int = 16
		hitbox.position.y -= extra_reach_px / 2.0
		var new_hitbox := RectangleShape2D.new()
		var y_length := (hitbox.shape as RectangleShape2D).size.y + extra_reach_px
		new_hitbox.size = Vector2(
			(hitbox.shape as RectangleShape2D).size.x, 
			y_length)
		var new_duration: float = seconds_per_pixel * y_length
		air_particles.lifetime = new_duration
		air_particles.amount = int(particles_per_secons * new_duration)
		hitbox.shape = new_hitbox

func _on_area_2d_body_entered(_body: Node2D) -> void:
	fan_collided.emit(self.rotation, own_index)

func _on_area_2d_body_exited(_body: Node2D) -> void:
	deactivated.emit(own_index)
