extends CharacterBody2D
# Child nodes
@onready var die_lines := $VoiceLines/Die/Die_1
@onready var jump_lines := $VoiceLines/Jump/Jump_1
@onready var fall_lines := $VoiceLines/FallToFloor/Landing_1
@onready var respawn_lines := $VoiceLines/Respawn/Respawn_1
@onready var find_line = $VoiceLines/Find/Find_1
@onready var jump_cooldown_timer := $Timers/JumpCooldownTimer
@onready var animated_sprites := $AnimatedSprite2D
@onready var left_cast := $RayCastLeft
@onready var right_cast := $RayCastRight
@onready var ray_cast_down_1 := $RayCastDown1
@onready var ray_cast_down_2 := $RayCastDown2
@onready var collision_shape_2d := $CollisionShape2D

# Player consts
const JUMP_OFF_WALL: float = 10000.0
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
const WALL_COLL_POS_R: float = 400.0
const WALL_COLL_POS_L: float = 410.0
const RAYC_COLL_POS_L: float = 45.0
const RAYC_COLL_POS_R: float = 40.0

# Control flow vars
var double_jump: bool = true
var double_jump_y: float
var current_state: States = States.GROUND
var spawn_pos: Vector2 = Vector2(-24, 259)

# Using signals to communicate to the outer nodes
signal animation_changed(animation: StringName)
signal velocity_changed(vel: StringName)
signal state_changed(state: StringName)

# Local signal
signal respawn

enum States {
	GROUND,
	AIR,
	WALL
}

func _ready() -> void:
	# Connect signals to external nodes
	var main: Node2D = get_node("../../Main")
	self.connect("animation_changed", Callable(main.get_node("CanvasLayer/Control/Animation"), "_on_animation_changed"))
	self.connect("velocity_changed", Callable(main.get_node("CanvasLayer/Control/Velocity"), "_on_velocity_changed"))
	self.connect("state_changed", Callable(main.get_node("CanvasLayer/Control/State"), "_on_state_changed"))
	# Connect own signal
	self.respawn.connect(Callable(self, "_on_respawn"))
	position = spawn_pos
	
func _physics_process(delta) -> void:
	# Debug: print on screen the animation, velocity and state
	emit_signal("animation_changed", animated_sprites.animation)
	emit_signal("velocity_changed", str(self.velocity))
	emit_signal("state_changed", str(States.keys()[current_state]))
	
	match current_state:
		States.GROUND:
			if not is_on_ground():
				change_state(States.AIR)
			ground_movement(delta)
		States.AIR:
			if is_on_ground():
				change_state(States.GROUND)
			# If colliding on wall, pressing either direction, and has not chnaged direction (which would get the player off the wall)
			elif is_coll_wall() and holding_x_direction() and !changed_direction():
				change_state(States.WALL)
			air_movement(delta)
		States.WALL:
			# Not pressing against a wall nor holding any direction, nor changed direction
			if not holding_x_direction() or !is_coll_wall() or changed_direction():
				change_state(States.AIR)
			elif is_on_ground():
				change_state(States.GROUND)
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
		change_state(States.AIR)

func exit_state(previous_state: States, new_state: States) -> void:
	match previous_state:
		# do some cleanup
		States.AIR:
			# If the player is not on the air anymore, reset their ability to double jump
			double_jump = true
			if new_state == States.GROUND:
				fall_lines.play()
				
func enter_state(new_state: States) -> void:
	match new_state:
		# do some logic
		States.WALL: 
			# Cancel the player's vertical momentum
			velocity.y = 0
	current_state = new_state

func change_state(new_state : States) -> void:
	exit_state(current_state, new_state)
	enter_state(new_state)

func die():
	animated_sprites.play("disappearing")
	#self.collision_shape_2d.call_deferred("set_disabled", true);
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
	return (ray_cast_down_1.is_colliding() or ray_cast_down_2.is_colliding()) && self.velocity.y == 0

func _on_kill_player():
	die()

func _on_checkpoint_triggered():
	self.set_respawn_pos(Vector2(self.global_position.x, self.global_position.y))

func _on_respawn():
	#collision_shape_2d.disabled = false
	position = spawn_pos
	velocity = Vector2.ZERO
	animated_sprites.play("appearing")
	respawn_lines.play()
	
func _on_dying_sfx_finished():
	# Continuation of die(), executed once the dying sound has finished playing
	emit_signal("respawn")

func _on_respawn_animation_finished():
	if animated_sprites.animation == "appearing":
		change_state(States.GROUND)
		set_physics_process(true)

func _on_fruit_collected():
	find_line.play()

# TODO: Introduce constants
func _on_fan_collision(delta):
	self.velocity.y -= 500.0 * delta
	
func _on_trampoline_jump():
	self.velocity.y -= 300.0

func set_respawn_pos(pos: Vector2):
	spawn_pos = pos
