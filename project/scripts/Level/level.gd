class_name GameManager
extends Node2D

@onready var player := $Player as PlayableCharacter
@onready var level := $Level as Node2D
@onready var world_border := $Level/WorldBorder as Area2D
@onready var checkpoints := $Level/Checkpoints as Node
@onready var level_ui := $LevelUI as CanvasLayer
@onready var score_label := level_ui.get_node("Score") as Label
@onready var level_finished := level_ui.get_node("LevelFinished") as LevelFinished
@onready var bgm := $Level/BGM as AudioStreamPlayer

# Scene containers
@onready var trampolines := $Level/Props/Trampolines as Node
@onready var fans := $Level/Props/Fans as Node
@onready var saws := $Level/Traps/Saws as Node
@onready var flamethrowers := $Level/Traps/Flamethrowers as Node
@onready var enemies := $Level/Enemies as Node
@onready var fruits := $Level/Fruits as Node

@export_category("Camera settings")
@export var left_limit: int = -10000000
@export var top_limit: int = -10000000
@export var right_limit: int = 10000000
@export var bottom_limit: int = 10000000
@export_category("")

const PLAYER_HEIGHT: float = 10.0

func _ready() -> void:
	
	# Match player's camera limit to the level bounds
	player.camera.limit_bottom = bottom_limit
	player.camera.limit_top = top_limit
	player.camera.limit_right = right_limit
	player.camera.limit_left = left_limit
	
	# Handle connections between the player and the level
	player.animation_changed.connect(Callable(level_ui.get_node("Control/Animation"), "_on_animation_changed"))
	player.velocity_changed.connect(Callable(level_ui.get_node("Control/Velocity"), "_on_velocity_changed"))
	player.state_changed.connect(Callable(level_ui.get_node("Control/State"), "_on_state_changed"))
	world_border.connect("kill_player", player._on_kill_player)
	
	# Setting the player's spawn position
	var start_pos := level.get_node("Checkpoints/Start") as StartCheckpoint
	var player_start_pos := start_pos.global_position
	# FIXME: why * 3?
	player.set_respawn_pos(Vector2(player_start_pos.x - PLAYER_HEIGHT * 3, player_start_pos.y - PLAYER_HEIGHT))
	
	# Connecting signals
	for trampoline: Trampoline in trampolines.get_children():
		trampoline.jumped_on.connect(player._on_trampoline_jump)
		
	for fan: Fan in fans.get_children():
		fan.fan_collided.connect(player._on_fan_collision)
	
	for saw in saws.get_children():
		saw.connect("kill_player", player._on_kill_player)
	
	for flamethrower in flamethrowers.get_children():
		flamethrower.connect("hit_flame", player._on_kill_player)
		
	for checkpoint in checkpoints.get_children():
		if checkpoint is Checkpoint:
			(checkpoint as Checkpoint).checkpoint_reached.connect(player._on_checkpoint_triggered)
		elif checkpoint is EndCheckpoint:
			(checkpoint as EndCheckpoint).level_finished.connect(_on_level_finished)
			
	for enemy_type in enemies.get_children():
		#if enemy_type.name in ["RockHead", "SpikeHead"]:
		# Contract: all enemies must have a kill_player signal
		# As there are no interfaces it is not possible to statically abide to this contract
		for enemy in enemy_type.get_children():
			enemy.connect("kill_player", player._on_kill_player)
			
	for fruit: Fruit in fruits.get_children():
		# Both connect to a method of the same name, but pertain to different nodes
		fruit.fruit_collected.connect(player._on_fruit_collected)
		fruit.fruit_score_changed.connect(Callable(score_label, "_on_fruit_collected"))
	
func _on_level_finished() -> void:
	player.set_physics_process(false)
	bgm.queue_free()
	level_finished.show()

