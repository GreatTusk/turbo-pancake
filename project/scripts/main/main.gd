class_name Main
extends Node

# The main ui and level manager are stored as packed scenes and not as children
# because they will be dynamically freed and instantiated
@export var main_ui_res: PackedScene
@export var level_manager_res: PackedScene


func _ready() -> void:
	#region load audio settings
	var audio_settings: AudioSettings
	# Save the default audio settings to user:// if this is the first time running the game
	if !FileAccess.file_exists("user://config/audio_settings.tres"):
		DirAccess.make_dir_absolute("user://config")
		audio_settings = ResourceLoader.load("res://resources/config/audio_settings.tres")
		ResourceSaver.save(audio_settings, "user://config/audio_settings.tres")
	else:
		# Load from user:// if they already exist
		audio_settings = ResourceLoader.load("user://config/audio_settings.tres")
	AudioServer.set_bus_volume_db(1, linear_to_db(audio_settings.bgm_volume))
	AudioServer.set_bus_volume_db(2, linear_to_db(audio_settings.sfx_volume))
	#endregion
	
	# Ignore return value - not useful here
	instantiate_main_ui()


func instantiate_main_ui() -> CanvasLayer:
	var main_ui := main_ui_res.instantiate()
	# Connect the level selected signal
	var level_selector := main_ui.get_node("LevelSelector") as LevelSelector
	level_selector.level_selected.connect(_on_level_selected)
	self.add_child(main_ui)
	return main_ui


func _on_level_selected(level_scene_path: String) -> void:
	# Instatiate the level manager. It contains the in-level ui
	var level_manager: LevelManager = level_manager_res.instantiate() as LevelManager
	# Go down the tree and connect signals
	assert(level_manager, "level manager failed")
	var level_modal := level_manager.get_node("LevelUI/LevelModal") as LevelModal
	assert(level_modal, "level modal not found")
	level_modal.level_selector_pressed.connect(_on_level_selector_pressed)
	level_modal.level_restarted.connect(_on_level_restarted)

	var level_finished := level_manager.get_node("LevelUI/LevelFinished") as LevelFinished
	assert(level_finished, "level finished not found")
	level_finished.level_selector_pressed.connect(_on_level_selector_pressed)
	level_finished.level_restarted.connect(_on_level_restarted)
	level_finished.next_level_pressed.connect(_on_next_level_pressed)
	level_finished.previous_level_pressed.connect(_on_previous_level_pressed)

	var main_ui := self.get_node_or_null("MainUI")
	# Checking so this method can be reused as is when restarting a level as well
	if main_ui:
		main_ui.queue_free()

	var level := (load(level_scene_path) as PackedScene).instantiate() as Level
	assert(level, "level is not valid")
	level_manager.add_child(level)
	self.add_child(level_manager)


func _on_level_selector_pressed() -> void:
	var level_manager := self.get_child(0)
	assert(level_manager is LevelManager)
	#self.remove_child.bind(level_manager).call_deferred()
	#self.remove_child(level_manager)
	level_manager.free.call_deferred()
	# TIL when using queue_free() the node is deleted only at the end of the frame, not inmediately
	# If we don't await for the node to exit the tree unintended behaviour might occur
	# Recreate the UI and set it so the level selector is visible
	var main_ui: CanvasLayer = instantiate_main_ui()
	(main_ui.get_node("TitleScreen") as TitleScreen).hide()
	(main_ui.get_node("LevelSelector") as LevelSelector).show()
	get_tree().paused = false


func _on_level_restarted() -> void:
	# If the level was restarted, we can assume the level manager is still valid
	var level_manager := self.get_child(0)
	assert(level_manager is LevelManager)
	var level_to_reset: Level = Singleton.rfind_node(level_manager, Level)
	assert(level_to_reset)
	# From here onwards, instead of replacing the level, the entire manager is replaced
	var level_path := level_to_reset.scene_file_path  # String
	level_manager.call_deferred("free")
	_on_level_selected(level_path)
	get_tree().paused = false


func _on_next_level_pressed() -> void:
	change_level(1)


func _on_previous_level_pressed() -> void:
	change_level(-1)


func change_level(direction: int) -> void:
	Singleton.current_level += direction
	const levels_folder := "res://scenes/levels/level_%s.tscn"
	var level_path := levels_folder % (Singleton.current_level)
	var level_manager := self.get_child(0)
	assert(level_manager is LevelManager)
	level_manager.free.call_deferred()
	_on_level_selected(level_path)
