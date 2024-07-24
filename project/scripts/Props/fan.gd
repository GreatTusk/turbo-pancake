class_name Fan
extends Node2D

@export var extra_reach_px: float = 0

@onready var sfx := $SFX/AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var air_particles := $AirParticles as GPUParticles2D
@onready var hitbox := $Area2D/Hitbox as CollisionShape2D

const FAN_IMPULSE: float = 12.0
signal fan_collided(velocity_applied: Vector2)

func _ready() -> void:	
	if extra_reach_px != 0:
		hitbox.position.y -= extra_reach_px / 2.0
		var new_hitbox := RectangleShape2D.new()
		new_hitbox.size = Vector2((hitbox.shape as RectangleShape2D).size.x, (hitbox.shape as RectangleShape2D).size.y + extra_reach_px)
		hitbox.shape = new_hitbox
	self.set_physics_process(false)

func _physics_process(_delta: float) -> void:
	fan_collided.emit(Vector2.UP.rotated(self.rotation) * FAN_IMPULSE) 

func _on_area_2d_body_entered(_body: Node2D) -> void:
	self.set_physics_process(true)

func _on_area_2d_body_exited(_body: Node2D) -> void:
	self.set_physics_process(false)
