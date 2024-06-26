extends RigidBody2D

var initial_pos: Vector2

enum STATES {
	AIR,
	FLOOR
}
var initial_state = STATES.AIR
var initial_pos_y

# Child nodes
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var blink_timer = $BlinkTimer
@onready var audio_stream_player_2d = $AudioStreamPlayer2D


func _ready():
	initial_pos_y = global_position.y
	self.set_physics_process(false)

func change_state(new_state: STATES):
	match new_state:
		STATES.FLOOR:
			animated_sprite_2d.play("bottom_hit")
	initial_state = new_state

func _physics_process(delta):
	match initial_state:
		STATES.AIR:
			if ray_cast_2d.is_colliding():
				audio_stream_player_2d.play()
				change_state(STATES.FLOOR)
		STATES.FLOOR:
			self.gravity_scale = -0.1
			if position.y <= initial_pos_y:
				self.gravity_scale = 1
				self.call_deferred("set", "freeze", true)
				change_state(STATES.AIR)

func _on_detection_area_body_entered(body):
	set_physics_process(true)
	blink_timer.start()

func _on_detection_area_body_exited(body):
	blink_timer.stop()
	animated_sprite_2d.play("idle")

func _on_blink_timer_timeout():
	animated_sprite_2d.play("blink")

func _on_direct_detection_body_entered(body):
	self.call_deferred("set", "freeze", false)

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "bottom_hit":
		animated_sprite_2d.play("idle")

func _on_hit_area_body_entered(body):
	#if body.is_on_ground():
	body.die()

#func _on_hit_area_body_entered(body: Player):
	##if body.is_on_ground():
	#body.die()
