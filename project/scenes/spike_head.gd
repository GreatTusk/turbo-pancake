extends StaticBody2D

@onready var path_follow_2d: = $".."
@onready var detect_cast_2: = $DetectCast2
@onready var detect_cast_3: = $DetectCast3
@onready var animated_sprite_2d: = $AnimatedSprite2D
@onready var falling_timer: = $FallingTimer
@onready var stunned_timer: = $StunnedTimer
@onready var ascending_timer: = $AscendingTimer
@onready var hit_floor_sfx = $HitFloorSFX

var hit_floor: bool = false
var offset: float
enum States {
	FALLING,
	ASCENDING,
	IDLE,
	STUNNED
}
var current_state: States = States.IDLE

func _physics_process(delta) -> void:
	match current_state:
		States.IDLE:
			if player_detected():
				falling_timer.start()
				current_state = States.FALLING
		States.FALLING:
			if hit_floor:
				stunned_timer.start()
				current_state = States.STUNNED
				return
			path_follow_2d.progress_ratio = max((timer_progress(falling_timer) - 1) * -1, 0)
		States.ASCENDING:
			if path_follow_2d.progress_ratio == 0.0:
				current_state = States.IDLE
			path_follow_2d.progress_ratio = max(timer_progress(ascending_timer) - offset, 0)

func player_detected() -> bool:
	return detect_cast_2.is_colliding() and detect_cast_2.get_collider() is CharacterBody2D || detect_cast_3.is_colliding() and detect_cast_3.get_collider() is CharacterBody2D

func timer_progress(timer: Timer) -> float:
	return timer.time_left / timer.wait_time
	
func _on_hitbox_body_entered(body) -> void:
	if body is TileMap or body is FloatingPlatform:
		hit_floor = true
		animated_sprite_2d.play("bottom_hit")
		hit_floor_sfx.play()
		offset = 1 - path_follow_2d.progress_ratio
	elif body is CharacterBody2D:
		body.die()

func _on_stunned_timer_timeout() -> void:
	hit_floor = false
	current_state = States.ASCENDING
	animated_sprite_2d.play("blink")
	ascending_timer.start()
