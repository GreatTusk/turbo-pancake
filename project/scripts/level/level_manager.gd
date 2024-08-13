class_name LevelManager
extends Node

# LevelUI
@onready var level_ui := $LevelUI as CanvasLayer
@onready var mobile_controls := level_ui.get_node("MobileControls") as Control
@onready var score_label := level_ui.get_node("Score") as Label
@onready var level_finished := level_ui.get_node("LevelFinished") as LevelFinished
@onready var player := $Player as PlayableCharacter

var defeatable_enemies_copy: Node
	
func initialize_level(level: Level) -> void:
	# Level nodes
	var world_border := level.get_node_or_null("WorldBorder") as Area2D
	var checkpoints := level.get_node_or_null("Checkpoints") as Node
	var trampolines := level.get_node_or_null("Props/Trampolines") as Node
	var fans := level.get_node_or_null("Props/Fans") as FanManager
	var saws := level.get_node_or_null("Traps/Saws") as Node
	var flamethrowers := level.get_node_or_null("Traps/Flamethrowers") as Node
	var enemies := level.get_node_or_null("Enemies") as Node
	var fruits := level.get_node_or_null("Fruits") as Node
	var tile_map_layers := level.get_node_or_null("TileMapLayers") as Node
	
	# The level must have at least one tilemap layer!
	assert(tile_map_layers.get_child_count() > 0)
	
	for layer in tile_map_layers.get_children():
		if layer is SpecialTileMapLayer:
			var cast_layer := layer as SpecialTileMapLayer
			player.request_tile_effect.connect(cast_layer._on_request_tile_effect)
			cast_layer.tile_effect_response.connect(player._on_tile_effect_response)
			cast_layer.particle_change_response.connect(player._on_particle_change_response)
	
	# The level must have a start point for the player to be valid!
	assert(checkpoints)
	for checkpoint in checkpoints.get_children():
		if checkpoint is Checkpoint:
			(checkpoint as Checkpoint).checkpoint_reached.connect(player._on_checkpoint_triggered)
			(checkpoint as Checkpoint).checkpoint_reached.connect(_on_update_enemies_copy.unbind(1))
			#var player_start_pos := (checkpoint as Checkpoint).global_position
			#player.set_respawn_pos(player_start_pos)
			#player.global_position = Vector2(player_start_pos.x, player_start_pos.y - player.PLAYER_HEIGHT)
		elif checkpoint is EndCheckpoint:
			(checkpoint as EndCheckpoint).level_finished.connect(_on_level_finished)
			(checkpoint as EndCheckpoint).level_finished.connect(level._on_level_finished)
		elif checkpoint is StartCheckpoint:
			var player_start_pos := (checkpoint as StartCheckpoint).global_position
			var pos := Vector2(player_start_pos.x, player_start_pos.y - player.PLAYER_HEIGHT)
			player.set_respawn_pos(pos)
			player.global_position = pos
				
	if world_border:
		world_border.connect("kill_player", player._on_kill_player)
	
	if trampolines:
		for trampoline: Trampoline in trampolines.get_children():
			trampoline.jumped_on.connect(player._on_trampoline_jump)
	
	if fans:
		fans.fan_collided.connect(player._on_fan_collision)

	if saws:
		for saw in saws.get_children():
			saw.connect("kill_player", player._on_kill_player)
	
	if flamethrowers:
		for flamethrower in flamethrowers.get_children():
			flamethrower.connect("hit_flame", player._on_kill_player)
	
	if enemies:
		var defeatable_enemies := enemies.get_node_or_null("DefeatableEnemies")
		var undefeatable_enemies := enemies.get_node_or_null("UndefeatableEnemies")
		
		if defeatable_enemies:
			defeatable_enemies_copy = defeatable_enemies.duplicate()
			connect_defeatable_enemies(defeatable_enemies)
						
		if undefeatable_enemies:
			for enemy_species in undefeatable_enemies.get_children():
				for enemy in enemy_species.get_children():
						enemy.connect("kill_player", player._on_kill_player)

	if fruits:
		var temp_fruit := Fruit.new()
		var fruit_property_hint: String = temp_fruit.get_property_list()[1]["hint_string"]
		var possible_fruits := fruit_property_hint.split(",")
		
		for fruit: Fruit in fruits.get_children():
			# EXPERIMENTAL:  Randomize the fruit
			fruit.fruit = possible_fruits[randi_range(0, possible_fruits.size() - 1)]
			# Both connect to a method of the same name, but pertain to different nodes
			fruit.fruit_collected.connect(player._on_fruit_collected)
			fruit.fruit_score_changed.connect(Callable(score_label, "_on_fruit_collected"))
		temp_fruit.queue_free()
		
func _on_level_finished() -> void:
	(level_ui.get_node("MenuButton") as TextureButton).hide()
	mobile_controls.hide()
	player.animated_sprites.stop()
	player.set_physics_process(false)
	level_finished.show()

func connect_player_and_level() -> void:
	
	var level: Level = Singleton.rfind_node(self, Level)
	assert(level)
	
	player.died.connect(_on_player_died)
	
	# Handle connections between the player and the ui
	player.animation_changed.connect(Callable(level_ui.get_node("Control/Animation"), "_on_animation_changed"))
	player.velocity_changed.connect(Callable(level_ui.get_node("Control/Velocity"), "_on_velocity_changed"))
	player.state_changed.connect(Callable(level_ui.get_node("Control/State"), "_on_state_changed"))
	
	# Set the player's camera bounds provided by the level
	player.camera.limit_bottom = level.bottom_limit
	player.camera.limit_top = level.top_limit
	player.camera.limit_right = level.right_limit
	player.camera.limit_left = level.left_limit
	
	if OS.has_feature("mobile"):
		player.camera.zoom = Vector2(1.2, 1.2)

	level_ui.show()
	initialize_level(level)

func _on_player_died() -> void:
	if defeatable_enemies_copy:
		# Find level
		var level: Level = Singleton.rfind_node(self, Level)
		assert(level)
		# Delete enemies
		var enemies_node := level.get_node("Enemies")
		var defeatable_enemies := enemies_node.get_node("DefeatableEnemies")
		enemies_node.remove_child(defeatable_enemies)
		defeatable_enemies.queue_free()
		# Add again and reconnect signals
		var enemies_to_add_back := defeatable_enemies_copy.duplicate()
		enemies_node.add_child(enemies_to_add_back)
		connect_defeatable_enemies(enemies_to_add_back)

func connect_defeatable_enemies(enemies: Node) -> void:
	for enemy_type in enemies.get_children():
		for enemy in enemy_type.get_children():
			if enemy is JumpableEnemy:
				(enemy as JumpableEnemy).enemy_jumped_on.connect(player._on_enemy_jumped)
				(enemy as JumpableEnemy).enemy_defeated.connect(Callable(score_label, "_on_fruit_collected"))
			elif enemy is Spawner:
				(enemy as Spawner).player = player
				(enemy as Spawner).score_label = score_label

func _on_update_enemies_copy() -> void:
	if defeatable_enemies_copy:
		# Find level
		var level: Level = Singleton.rfind_node(self, Level)
		assert(level)
		defeatable_enemies_copy = level.get_node("Enemies/DefeatableEnemies").duplicate()

func _ready() -> void:
	connect_player_and_level()
