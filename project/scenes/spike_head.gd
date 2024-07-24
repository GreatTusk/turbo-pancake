class_name SpikeHead
extends Node2D

@onready var path_follow_2d := $Path2D/PathFollow2D as PathFollow2D
@onready var detect_cast_2 := $Path2D/PathFollow2D/Body/DetectCast2 as RayCast2D
@onready var detect_cast_3 := $Path2D/PathFollow2D/Body/DetectCast3 as RayCast2D
@onready var animated_sprite_2d := $Path2D/PathFollow2D/Body/AnimatedSprite2D as AnimatedSprite2D
@onready var falling_timer := $Path2D/PathFollow2D/Body/FallingTimer as Timer
@onready var stunned_timer := $Path2D/PathFollow2D/Body/StunnedTimer as Timer
@onready var ascending_timer := $Path2D/PathFollow2D/Body/AscendingTimer as Timer
@onready var hit_floor_sfx := $Path2D/PathFollow2D/Body/HitFloorSFX as AudioStreamPlayer2D

var hit_floor: bool = false
var offset: float
enum States {
	FALLING,
	ASCENDING,
	IDLE,
	STUNNED
}
var current_state: States = States.IDLE

signal kill_player

func _physics_process(_delta: float) -> void:
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
	return (detect_cast_2.is_colliding() || detect_cast_3.is_colliding())

func timer_progress(timer: Timer) -> float:
	return timer.time_left / timer.wait_time
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is TileMap or body is FloatingPlatform:
		hit_floor = true
		animated_sprite_2d.play("bottom_hit")
		hit_floor_sfx.play()
		offset = 1 - path_follow_2d.progress_ratio
	elif body is PlayableCharacter:
		kill_player.emit()

func _on_stunned_timer_timeout() -> void:
	hit_floor = false
	current_state = States.ASCENDING
	animated_sprite_2d.play("blink")
	ascending_timer.start()
