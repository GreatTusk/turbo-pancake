class_name GameManager
extends Node2D

@onready var player := $Player as PlayableCharacter
@onready var level := $Level as Node2D
@onready var world_border := $Level/WorldBorder as Area2D
@onready var checkpoints := $Level/Checkpoints as Node
@onready var level_ui := $LevelUI as CanvasLayer
@onready var score_label := level_ui.get_node("Score") as Label
# Scene containers
@onready var trampolines := $Level/Props/Trampolines as Node
@onready var fans := $Level/Props/Fans as Node
@onready var saws := $Level/Traps/Saws as Node
@onready var flamethrowers := $Level/Traps/Flamethrowers as Node
@onready var enemies := $Level/Enemies as Node
@onready var fruits := $Level/Fruits as Node


#@export var player_y_spawn_pos: float = 0.0

const PLAYER_HEIGHT: float = 10.0

func _ready() -> void:
	# Handle connections between the player and the level
	player.connect("animation_changed", Callable(level_ui.get_node("Control/Animation"), "_on_animation_changed"))
	player.connect("velocity_changed", Callable(level_ui.get_node("Control/Velocity"), "_on_velocity_changed"))
	player.connect("state_changed", Callable(level_ui.get_node("Control/State"), "_on_state_changed"))
	world_border.connect("kill_player", Callable(player, "_on_kill_player"))
	
	# Setting the player's spawn position
	var start_pos := level.get_node("Checkpoints/Start") as StartCheckpoint
	var player_start_pos := start_pos.global_position
	player.set_respawn_pos(Vector2(player_start_pos.x - PLAYER_HEIGHT * 3, player_start_pos.y - PLAYER_HEIGHT))
	
	# Connecting signals
	for trampoline in trampolines.get_children():
		trampoline.connect("jumped_on", Callable(player, "_on_trampoline_jump"))
		
	for fan in fans.get_children():
		fan.connect("fan_collided", Callable(player, "_on_fan_collision"))
	
	for saw in saws.get_children():
		saw.connect("kill_player", Callable(player, "_on_kill_player"))
	
	for flamethrower in flamethrowers.get_children():
		flamethrower.connect("hit_flame", Callable(player, "_on_kill_player"))
		
	for checkpoint in checkpoints.get_children():
		if checkpoint is Checkpoint:
			(checkpoint as Checkpoint).respawn_player.connect(Callable(player, "_on_checkpoint_triggered"))
		elif checkpoint is EndCheckpoint:
			(checkpoint as EndCheckpoint).level_finished.connect(Callable(self, "_on_level_finished"))
	
	for enemy_type in enemies.get_children():
		#if enemy_type.name in ["RockHead", "SpikeHead"]:
		# Contract: all enemies must have a kill_player signal
		for enemy in enemy_type.get_children():
			enemy.connect("kill_player", Callable(player, "_on_kill_player"))
	
	for fruit in fruits.get_children():
		# Both connect to a method of the same name, but pertain to different nodes
		fruit.connect("fruit_collected", Callable(player, "_on_fruit_collected"))
		fruit.connect("fruit_score_changed", Callable(score_label, "_on_fruit_collected"))
		
func _on_level_finished() -> void:
	print("Finished")

