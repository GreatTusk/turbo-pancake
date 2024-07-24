class_name RockHead
extends RigidBody2D

var initial_pos: Vector2

enum States {
	AIR,
	FLOOR
}
var initial_state: States = States.AIR
var initial_pos_y: float

# Child nodes
@onready var animated_sprite_2d := $AnimatedSprite2D as AnimatedSprite2D
@onready var ray_cast_2d := $RayCast2D as RayCast2D
@onready var blink_timer := $BlinkTimer as Timer
@onready var audio_stream_player_2d := $AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var crush_particles := $CrushParticles as GPUParticles2D

signal kill_player

func _ready() -> void:
	initial_pos_y = global_position.y
	self.set_physics_process(false)

func change_state(new_state: States) -> void:
	match new_state:
		States.FLOOR:
			crush_particles.emitting = true
			animated_sprite_2d.play("bottom_hit")
	initial_state = new_state

func _physics_process(_delta: float) -> void:
	match initial_state:
		States.AIR:
			if ray_cast_2d.is_colliding():
				audio_stream_player_2d.play()
				change_state(States.FLOOR)
		States.FLOOR:
			self.gravity_scale = -0.1
			if position.y <= initial_pos_y:
				self.gravity_scale = 1
				self.call_deferred("set", "freeze", true)
				change_state(States.AIR)

func _on_detection_area_body_entered(_body: PlayableCharacter) -> void:
	set_physics_process(true)
	blink_timer.start()

func _on_detection_area_body_exited(_body: PlayableCharacter) -> void:
	blink_timer.stop()
	animated_sprite_2d.play("idle")

func _on_blink_timer_timeout() -> void:
	animated_sprite_2d.play("blink")

func _on_direct_detection_body_entered(_body: PlayableCharacter) -> void:
	self.call_deferred("set", "freeze", false)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "bottom_hit":
		animated_sprite_2d.play("idle")

func _on_hit_area_body_entered(_body: PlayableCharacter) -> void:
	#if body.is_on_ground():
	emit_signal("kill_player")

