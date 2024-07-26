class_name LevelManager
extends Node2D

"""
TODO: It feels wasteful to reload the entire level manager when the only node
that makes sense to be replaced is the current level that is loaded.
But at the same time, it feels like returning the player and the level to their
original state would be more expensive than reloading them.
""" 

# LevelUI
@onready var level_ui := $LevelUI as CanvasLayer
@onready var score_label := level_ui.get_node("Score") as Label
@onready var level_finished := level_ui.get_node("LevelFinished") as LevelFinished
@onready var player := $Player as PlayableCharacter
var player_ui_ready: bool = false
	
func initialize_level(level: Level) -> void:
	# Level nodes
	var world_border := level.get_node_or_null("WorldBorder") as Area2D
	var checkpoints := level.get_node_or_null("Checkpoints") as Node
	var trampolines := level.get_node_or_null("Props/Trampolines") as Node
	var fans := level.get_node_or_null("Props/Fans") as Node
	var saws := level.get_node_or_null("Traps/Saws") as Node
	var flamethrowers := level.get_node_or_null("Traps/Flamethrowers") as Node
	var enemies := level.get_node_or_null("Enemies") as Node
	var fruits := level.get_node_or_null("Fruits") as Node
	
	if world_border:
		world_border.connect("kill_player", player._on_kill_player)
	
	if trampolines:
		for trampoline: Trampoline in trampolines.get_children():
			trampoline.jumped_on.connect(player._on_trampoline_jump)
	
	if fans:
		for fan: Fan in fans.get_children():
			fan.fan_collided.connect(player._on_fan_collision)
		
	if saws:
		for saw in saws.get_children():
			saw.connect("kill_player", player._on_kill_player)
	
	if flamethrowers:
		for flamethrower in flamethrowers.get_children():
			flamethrower.connect("hit_flame", player._on_kill_player)
	
	# The level must have a start point for the player to be valid!
	assert(checkpoints)
	for checkpoint in checkpoints.get_children():
		if checkpoint is Checkpoint:
			(checkpoint as Checkpoint).checkpoint_reached.connect(player._on_checkpoint_triggered)
		elif checkpoint is EndCheckpoint:
			(checkpoint as EndCheckpoint).level_finished.connect(_on_level_finished)
			(checkpoint as EndCheckpoint).level_finished.connect(level._on_level_finished)
		elif checkpoint is StartCheckpoint:
			var player_start_pos := (checkpoint as StartCheckpoint).global_position
			# TODO: tweak
			player.set_respawn_pos(player_start_pos)
			player.global_position = Vector2(player_start_pos.x, player_start_pos.y - player.PLAYER_HEIGHT)
	if enemies:
		for enemy_type in enemies.get_children():
			#if enemy_type.name in ["RockHead", "SpikeHead"]:
			# Contract: all enemies must have a kill_player signal
			# As there are no interfaces it is not possible to statically abide to this contract
			for enemy in enemy_type.get_children():
				enemy.connect("kill_player", player._on_kill_player)
	
	if fruits:
		for fruit: Fruit in fruits.get_children():
			# Both connect to a method of the same name, but pertain to different nodes
			fruit.fruit_collected.connect(player._on_fruit_collected)
			fruit.fruit_score_changed.connect(Callable(score_label, "_on_fruit_collected"))
	
func _on_level_finished() -> void:
	player.set_physics_process(false)
	level_finished.show()

func connect_player_to_level() -> void:
	# Assume that the index 2 will contain the level
	var level: Level = self.get_child(2)
	assert(level is Level)
	# Handle connections between the player and the ui
	player.animation_changed.connect(Callable(level_ui.get_node("Control/Animation"), "_on_animation_changed"))
	player.velocity_changed.connect(Callable(level_ui.get_node("Control/Velocity"), "_on_velocity_changed"))
	player.state_changed.connect(Callable(level_ui.get_node("Control/State"), "_on_state_changed"))
	# Set the player's camera bounds
	player.camera.limit_bottom = level.bottom_limit
	player.camera.limit_top = level.top_limit
	player.camera.limit_right = level.right_limit
	player.camera.limit_left = level.left_limit
	level_ui.show()
	initialize_level(level)


func _ready() -> void:
	connect_player_to_level()
	
