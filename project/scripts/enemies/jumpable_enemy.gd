@icon("res://gd_extension_icons/jump.svg")
class_name JumpableEnemy
extends CharacterBody2D

# Define properties and signals common to all jumpable enemies
@export var jumpable: bool = true
@export var health: int = 1
@export var initial_velocity: Vector2
@export var jumped_on_threshold: float
@export var after_hit_animation: StringName

var animated_sprite: AnimatedSprite2D
var interaction_timer: Timer
var hurt_sfx: AudioStreamPlayer2D
var death_sfx: AudioStreamPlayer2D
#var collided := false

signal enemy_jumped_on
signal stuck(coll_normal: Vector2)

# Function to handle what happens when the enemy is jumped on
func _on_jumped_on() -> void:
	enemy_jumped_on.emit()
	var hit_or_die: bool = health > 1
	
	animated_sprite.play(&"hit" if hit_or_die else &"die")
	(hurt_sfx if hit_or_die else death_sfx).play()

# Function to handle damage taken by the enemy
func take_damage(amount: int = 1) -> void:
	health -= amount
	animated_sprite.play(after_hit_animation)

# Function to handle the enemy's death
func die() -> void:
	self.set_physics_process(false)
	queue_free()

func _on_animation_finished() -> void:
	match animated_sprite.animation:
		&"hit":
			take_damage()
		&"die":
			die()

# Basic handling of collisions
func _physics_process(delta: float) -> void:
	
	if !interaction_timer.is_stopped():
		return
	
	#move_and_slide()
	#
	#var collision: KinematicCollision2D = get_last_slide_collision()
	#if collision && !collided:
		#var collider := collision.get_collider()
		#collided = true
		#if collider is PlayableCharacter:
			#var player_coll := collider as PlayableCharacter
			## To kill, or be killed?
			#print(self.position.y - player_coll.position.y)
			#if self.position.y - player_coll.position.y > jumped_on_threshold && jumpable:
				#_on_jumped_on()
			#else:
				#player_coll._on_kill_player()
	#else:
		#collided = false
	
	#for i in get_slide_collision_count():
		#var collision: KinematicCollision2D = get_slide_collision(i)
		#var collider := collision.get_collider()
		#if collider is PlayableCharacter:
			#var player_coll := collider as PlayableCharacter
			## To kill, or be killed?
			#print(self.position.y - player_coll.position.y)
			#if self.position.y - player_coll.position.y > jumped_on_threshold && jumpable:
				#_on_jumped_on()
			#else:
				#player_coll._on_kill_player()
			#return

	var collision: KinematicCollision2D = move_and_collide(self.velocity * delta)
	
	if collision:
		var collider := collision.get_collider()
		if collider is PlayableCharacter:
			interaction_timer.start()
			var player_coll: PlayableCharacter = collider 
			# To kill, or be killed?
			print(self.position.y - player_coll.position.y)
			if self.position.y - player_coll.position.y > jumped_on_threshold && jumpable:
				_on_jumped_on()
			else:
				player_coll._on_kill_player()
		elif collider is TileMapLayer:
			var coll_normal: Vector2 = collision.get_normal()
			if self is Bat:
				stuck.emit(coll_normal)
			# elif self is ...
