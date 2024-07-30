extends Node

# The main ui and level manager are stored as packed scenes and not as children
# because they will be dynamically freed and instantiated
@export var main_ui_res: PackedScene
@export var level_manager_res: PackedScene

func _ready() -> void:
	# Ignore return value - not useful here
	#if OS.has_feature("mobile"):
		## TODO: Fix the touchscreen controls to the sides of the screen
		#get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	instantiate_main_ui()
	
func instantiate_main_ui() -> CanvasLayer:
	var main_ui := main_ui_res.instantiate()
	self.add_child(main_ui)
	# Connect the level selected signal
	var level_selector := main_ui.get_node("LevelSelector") as LevelSelector
	level_selector.level_selected.connect(_on_level_selected)
	return main_ui

func _on_level_selected(level_scene_path: String) -> void:
	# Instatiate the level manager. It contains the in-level ui
	var level_manager: LevelManager = level_manager_res.instantiate() as LevelManager
	# Go down the tree and connect signals
	var level_modal := level_manager.get_node("LevelUI/LevelModal") as LevelModal
	level_modal.level_selector_pressed.connect(_on_level_selector_pressed)
	level_modal.level_restarted.connect(_on_level_restarted)
	
	var level_finished := level_manager.get_node("LevelUI/LevelFinished") as LevelFinished
	level_finished.level_selector_pressed.connect(_on_level_selector_pressed)
	level_finished.level_restarted.connect(_on_level_restarted)
	level_finished.next_level_pressed.connect(_on_next_level_pressed)
	level_finished.previous_level_pressed.connect(_on_previous_level_pressed)
	
	var main_ui := self.get_node_or_null("MainUI")
	# Checking so this method can be reused as is when restarting a level as well
	if main_ui:
		main_ui.queue_free()
	
	var level := (load(level_scene_path) as PackedScene).instantiate() as Level
	level_manager.add_child(level)
	self.add_child(level_manager)
	
func _on_level_selector_pressed() -> void:
	# The level will always be the first and only child
	var level_to_delete := self.get_child(0)
	level_to_delete.queue_free()
	# TIL when using queue_free() the node is deleted only at the end of the frame, not inmediately
	# If we don't await for the node to exit the tree unintended behaviour might occur
	# Another alternative: level_to_delete.call_deferred("free")
	await level_to_delete.tree_exited
	# Recreate the UI and set it so the level selector is visible
	var main_ui: CanvasLayer = instantiate_main_ui()
	(main_ui.get_node("TitleScreen") as TitleScreen).hide()
	(main_ui.get_node("LevelSelector") as LevelSelector).show()
	get_tree().paused = false

func _on_level_restarted() -> void:
	# If the level was restarted, we can assume the level manager is still valid
	var level_manager := self.get_child(0) 
	assert(level_manager)
	
	var level_to_reset: Level
	for i in range(level_manager.get_child_count() - 1, -1, -1):
		var child := level_manager.get_child(i)
		if child is Level:
			level_to_reset = child
			break
			
	# From here onwards, instead of replacing the level, the entire manager is replaced
	var level_path := level_to_reset.scene_file_path # String
	level_manager.call_deferred("free")
	_on_level_selected(level_path)
	get_tree().paused = false
	
	# Tried to reload only the level, proved to be too difficult
	
	#var level_path := level_to_reset.scene_file_path # String
	#var new_level := (load(level_path) as PackedScene).instantiate()
	#level_to_reset.call_deferred("free")
	#level_manager.add_child(new_level)
	#level_manager.request_ready()
	#for node in level_manager.get_children():
		#node.request_ready()
		#await node.ready
	#get_tree().paused = false
	#var player := level_manager.get_node("Player") as PlayableCharacter
	#player.global_position = player.spawn_pos
	#(level_manager.level_ui as LevelUI).level_modal.hide()

func _on_next_level_pressed() -> void:
	change_level(1)

func _on_previous_level_pressed() -> void:
	change_level(-1)

func change_level(direction: int) -> void:
	Singleton.current_level += direction
	var level_path := "res://scenes/levels/level_%s.tscn" % (Singleton.current_level)
	var level_manager := self.get_child(0) 
	assert(level_manager)
	level_manager.call_deferred("free")
	_on_level_selected(level_path)



