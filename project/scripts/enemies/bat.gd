class_name Bat
extends JumpableEnemy

@onready var ceiling_cast_l: RayCast2D = $CeilingCastL
@onready var ceiling_cast_r: RayCast2D = $CeilingCastR
@onready var player_ray_casts: Node2D = $PlayerRayCasts
@onready var ceiling_hitbox: CollisionShape2D = $CeilingHitbox
@onready var flying_hitbox: CollisionShape2D = $FlyingHitbox

enum State {
	IDLE,
	CEILING,
	PLAYER
}

const CEILING_SPEED: float = 70.0
const PLAYER_CHASING_SPEED: float = 50.0
const MAX_DETECTION_DIST: float = 200.0
var current_state: State = State.IDLE
var ceiling_pos: Vector2
var player_raycasts: Array[RayCast2D]
var player: PlayableCharacter

func _ready() -> void:
	ceiling_pos = self.global_position
	# Initialize vars from super class
	interaction_timer = $Timers/InteractionTimer
	animated_sprite = $Sprites
	hurt_sfx = $SFX/Hurt
	death_sfx = $SFX/Death
	animated_sprite.animation_finished.connect(_on_animation_finished)
	stuck.connect(_on_stuck)
	self.velocity = initial_velocity
	
	var total_rays: int = player_ray_casts.get_child_count()
	player_raycasts.resize(total_rays)
	for i in range(total_rays):
		player_raycasts[i] = player_ray_casts.get_child(i)
	
func _physics_process(delta: float) -> void:
	# Let's make it get out of the ceiling when it detects a player nearby
	match current_state:
		State.IDLE:
			idle()
		State.CEILING:
			go_to_ceiling(delta)
		State.PLAYER:
			follow_player(delta)
			# Only call the parent's class physiscs process here because
			# only when moving towards the player we enable it to collide with it.
			super._physics_process(delta)

func idle() -> void:
	# Looking for the player
	for cast: RayCast2D in player_raycasts:
		if is_raycast_colliding_with(cast, PlayableCharacter):
			player = cast.get_collider()
			change_state(State.PLAYER)

func go_to_ceiling(delta: float) -> void:
	animated_sprite.flip_h = self.velocity.x > 0
	self.velocity = (self.global_position - ceiling_pos).normalized() * -CEILING_SPEED 
	var ceiling: KinematicCollision2D = move_and_collide(self.velocity * delta)
	# Reached the ceiling?
	if ceiling && ceiling.get_collider() is TileMapLayer:
		var collision_normal: Vector2 = ceiling.get_normal()
		if collision_normal.x != 0:
			self.rotate(deg_to_rad(90.0 * -collision_normal.x))
			var tween := self.create_tween()
			tween.tween_property(self, "global_position", Vector2(self.global_position.x + 8.5 * -signf(collision_normal.x), self.global_position.y), 0.4)
		change_state(State.IDLE)

func follow_player(_delta: float) -> void:
	if (self.global_position.distance_to(player.global_position) > MAX_DETECTION_DIST 
	|| player_raycasts.all(is_raycast_colliding_with.bind(PlayableCharacter))):
		# Back to the celing or starting point
		change_state(State.CEILING)
		return
	animated_sprite.flip_h = self.velocity.x >= 0
	self.velocity = (player.global_position - self.global_position).normalized() * PLAYER_CHASING_SPEED
	
func find_ceiling() -> Vector2:
	# Looking for the ceiling
	var valid_casts: Array[RayCast2D]
	for cast: RayCast2D in [ceiling_cast_l, ceiling_cast_r]:
		if is_raycast_colliding_with(cast, TileMapLayer):
			valid_casts.append(cast)
	if valid_casts.size() > 0:
		return valid_casts.pick_random().get_collision_point()
	return Vector2.ZERO


func change_state(new_state: State) -> void:
	match new_state:
		State.PLAYER:
			animated_sprite.play(&"ceiling_out")
			if self.rotation != 0:
				var tween := self.create_tween()
				tween.tween_property(self, "rotation", deg_to_rad(0.0), 0.4)
		State.CEILING:
			player = null
			var new_pos: Vector2 = find_ceiling()
			if new_pos != Vector2.ZERO:
				ceiling_pos = new_pos
			restore_ray_casts_length()
		State.IDLE:
			self.velocity = Vector2.ZERO
			animated_sprite.play(&"ceiling_in")
	current_state = new_state

func is_raycast_colliding_with(cast: RayCast2D, type: Variant) -> bool: 
	return cast.is_colliding() && is_instance_of(cast.get_collider(), type)

func _on_stuck(collision_normal: Vector2) -> void:
	# Assume player is out of sight
	#var lost_player: bool = true
	for ray in player_raycasts:
		if is_raycast_colliding_with(ray, TileMapLayer):
			Singleton.reajust_raycast_target(ray)
		# Prove it wrong
		#lost_player = !is_raycast_colliding_with(ray, PlayableCharacter)
		#if !lost_player:
			#break

	if player:
		# If stuck on a wall
		if abs(collision_normal.x) > 0.5:
			self.velocity.y = -PLAYER_CHASING_SPEED if self.global_position.y > player.global_position.y else PLAYER_CHASING_SPEED
		elif collision_normal.y < -0.5:
			self.velocity.x = sign(self.velocity.x) * PLAYER_CHASING_SPEED
		move_and_slide()

func restore_ray_casts_length() -> void:
	var x_vals: PackedFloat32Array = [-152, 152, 0, 152, -152]
	var y_vals: PackedFloat32Array = [152, 152, 152, 0, 0]
	for i in player_raycasts.size():
		player_raycasts[i].target_position = Vector2(x_vals[i], y_vals[i])

# Handling animation transitions
func _on_animation_finished() -> void:
	match animated_sprite.animation:
		&"ceiling_out":
			animated_sprite.play(&"flying")
			ceiling_hitbox.disabled = true
			flying_hitbox.disabled = false
		&"ceiling_in":
			animated_sprite.play(&"idle")
			ceiling_hitbox.disabled = false
			flying_hitbox.disabled = true
		&"hit", &"die":
			super._on_animation_finished()
