extends CharacterBody2D

# Child nodes
@onready var die_lines = $VoiceLines/Die/Die_1
@onready var jump_lines = $VoiceLines/Jump/Jump_1
@onready var fall_lines = $VoiceLines/FallToFloor/Landing_1
@onready var respawn_lines = $VoiceLines/Respawn/Respawn_1
@onready var jump_cooldown_timer = $Timers/JumpCooldownTimer
@onready var animated_sprites = $AnimatedSprite2D
@onready var left_cast = $RayCastLeft
@onready var right_cast = $RayCastRight
@onready var ray_cast_down_1 = $RayCastDown1
@onready var ray_cast_down_2 = $RayCastDown2
@onready var collision_shape_2d = $CollisionShape2D

# Player consts
const JUMP_VEL: float = -200.0
const WALL_VEL: float = 120.0
const WALL_FRICTION: float = 0.1
const DOUBLE_JUMP_VEL: float = JUMP_VEL * 1.2
const MAX_SPEED_X: float = 200.0
const MAX_SPEED_Y: float = 900.0
const ACC: float = 400.0
const AIR_ACC_Y: float = 620.0
const GROUND_DEC: float = 900.0
const AIR_DEC_X: float = 450.0
const WALL_COLL_POS_R: int = 400
const WALL_COLL_POS_L: int = 410
const RAYC_COLL_POS_L: int = 45
const RAYC_COLL_POS_R: int = 40

# Control flow vars
var double_jump: bool = true
var double_jump_y: float
var current_state: STATES = STATES.GROUND

# References to external nodes
var main: Node2D
var animation_label: Label
var velocity_label: Label
var state_label: Label

signal respawn

# Get the gravity from the project settings to be synced with RigidBody nodes.
# 600
#var gravity = ProjectSettings.get("physics/2d/default_gravity")

enum STATES {
	GROUND,
	AIR,
	WALL
}

func _ready():
	# Initialize references to external nodes
	main = get_node("../../Main")
	position = main.get_respawn_pos()
	animation_label = main.get_node("CanvasLayer/Control/Animation")
	velocity_label = main.get_node("CanvasLayer/Control/Velocity")
	state_label = main.get_node("CanvasLayer/Control/State")
	respawn.connect(Callable(self, "_on_respawn"))
	
func _physics_process(delta):
	# Debug: print on screen the animation, velocity and state
	self.animation_label.set_text(animated_sprites.animation)
	self.velocity_label.set_text(str(self.velocity))
	self.state_label.set_text(str(STATES.keys()[current_state]))
	
	match current_state:
		STATES.GROUND:
			if not is_on_ground():
				change_state(STATES.AIR)
			ground_movement(delta)
		STATES.AIR:
			if is_on_ground():
				change_state(STATES.GROUND)
			# If colliding on wall, pressing either direction, and has not chnaged direction (which would get the player off the wall)
			elif is_coll_wall() and holding_x_direction() and !changed_direction():
				change_state(STATES.WALL)
			air_movement(delta)
		STATES.WALL:
			# Not pressing against a wall nor holding any direction, nor changed direction
			if not holding_x_direction() or !is_coll_wall() or changed_direction():
				change_state(STATES.AIR)
			elif is_on_ground():
				change_state(STATES.GROUND)
			wall_movement(delta)
	move_and_slide()

func ground_movement(delta) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		jump_lines.play()
		velocity.y = JUMP_VEL
		# Return - if we've jumped we're no longer in the ground
		return
		
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		animated_sprites.play("run")
		animated_sprites.flip_h = direction < 0
		velocity.x = move_toward(self.velocity.x, direction * MAX_SPEED_X, ACC * delta)
	else:
		animated_sprites.play("idle")
		self.velocity.x = move_toward(self.velocity.x, 0, GROUND_DEC * delta)
	
func air_movement(delta) -> void:
	# Fall faster if going down
	velocity.y = move_toward(velocity.y, MAX_SPEED_Y, AIR_ACC_Y * delta)
	#velocity.y += ((gravity + ACC) * delta) if velocity.y < 0 else ((gravity + ACC) * delta * 1.5)
	adjust_hitbox()
	
	if Input.is_action_just_pressed("jump") and double_jump:
		animated_sprites.play("double_jump")
		jump_lines.play()
		velocity.y = DOUBLE_JUMP_VEL
		double_jump = false
		double_jump_y = self.position.y
	# If not double jumping and moving upwards
	elif velocity.y < 0 and animated_sprites.animation != "double_jump":
		animated_sprites.play("jump")
	# If affected by gravity and not double jumping, or after double jumping
	elif velocity.y > 0 and (animated_sprites.animation != "double_jump" or self.position.y >= double_jump_y):
		animated_sprites.play("fall")
		
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		animated_sprites.flip_h = direction < 0
		velocity.x = move_toward(self.velocity.x, direction * MAX_SPEED_X, ACC * delta)
	else:
		self.velocity.x = move_toward(self.velocity.x, 0, AIR_DEC_X * delta)
	
func wall_movement(delta):
	animated_sprites.play("wall_jump")
	# Simulate friction when on a wall
	velocity.y = move_toward(velocity.y, MAX_SPEED_Y, AIR_ACC_Y * delta * WALL_FRICTION)
	
	if Input.is_action_just_pressed("jump"):
		animated_sprites.play("jump")
		# Use of a timer to prevent the player from going up a wall while stuck on it
		jump_cooldown_timer.start()
		jump_lines.play()
		# Move right or left depending on where the player is facing
		velocity.x = WALL_VEL * (1 if animated_sprites.flip_h else -1)
		velocity.y = JUMP_VEL
		change_state(STATES.AIR)

func exit_state(previous_state: STATES, new_state: STATES) -> void:
	match previous_state:
		# do some cleanup
		STATES.AIR:
			# If the player is not on the air anymore, reset their ability to double jump
			double_jump = true
			if new_state == STATES.GROUND:
				fall_lines.play()
				
func enter_state(new_state: STATES) -> void:
	match new_state:
		# do some logic
		STATES.WALL: 
			# Cancel the player's vertical momentum
			velocity.y = 0
	current_state = new_state

func change_state(new_state : STATES) -> void:
	exit_state(current_state, new_state)
	enter_state(new_state)

func die():
	animated_sprites.play("disappearing")
	# Prevent the player from moving
	set_physics_process(false)
	die_lines.play()

# Helper functions
func holding_x_direction() -> bool:
	return Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")

func changed_direction() -> bool:
	return (Input.is_action_pressed("move_left") and !animated_sprites.flip_h) or (Input.is_action_pressed("move_right") and animated_sprites.flip_h)

func adjust_hitbox() -> void:
	if animated_sprites.flip_h:
		# If holding right
		collision_shape_2d.position.x = WALL_COLL_POS_L
		right_cast.target_position.x = RAYC_COLL_POS_L
		left_cast.target_position.x = RAYC_COLL_POS_L
	else:
		collision_shape_2d.position.x = WALL_COLL_POS_R
		right_cast.target_position.x = RAYC_COLL_POS_R
		left_cast.target_position.x = RAYC_COLL_POS_R


	
func is_coll_wall() -> bool:
	# Check the left or right cast depending on which way the player is facing
	return (left_cast if animated_sprites.flip_h else right_cast).is_colliding()

func is_on_ground():
	return ray_cast_down_1.is_colliding() or ray_cast_down_2.is_colliding()

func _on_world_border_entered(body):
	die()

func _on_respawn():
	position = main.get_respawn_pos()
	animated_sprites.play("appearing")
	respawn_lines.play()
	
func _on_dying_sfx_finished():
	# Continuation of die(), executed once the dying sound has finished playing
	emit_signal("respawn")

func _on_respawn_animation_finished():
	if animated_sprites.animation == "appearing":
		change_state(STATES.GROUND)
		set_physics_process(true)
