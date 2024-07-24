extends Node

@export var main_ui_res: PackedScene

func _ready() -> void:
	instantiate_main_ui()
	
func instantiate_main_ui() -> CanvasLayer:
	var main_ui := main_ui_res.instantiate()
	self.add_child(main_ui)
	# Connect the level selected signal
	var level_selector := main_ui.get_node("LevelSelector") as LevelSelector
	level_selector.level_selected.connect(_on_level_selected)
	return main_ui

func _on_level_selected(level_scene_path: String, level_index: int = 0) -> void:
	# Returns a Node. The actual type is a Node2D but it doesn't matter
	var level := (load(level_scene_path) as PackedScene).instantiate()
	# Go down the tree and connect the go back to the UI and connect signals
	var level_modal := level.get_node("LevelUI/LevelModal") as LevelModal
	level_modal.level_selector_pressed.connect(_on_level_selector_pressed)
	level_modal.level_restarted.connect(_on_level_restarted)
	
	var level_finished := level.get_node("LevelUI/LevelFinished") as LevelFinished
	level_finished.level_selector_pressed.connect(_on_level_selector_pressed)
	level_finished.level_restarted.connect(_on_level_restarted)
	level_finished.current_level = level_index
	
	var main_ui := self.get_node_or_null("MainUI")
	# Checking so this method can be reused as is when restarting a level as well
	if main_ui:
		main_ui.queue_free()
	self.add_child(level)
	
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
	var level_to_reset := self.get_child(0)
	# It's a string, duh
	var level_path := level_to_reset.scene_file_path
	level_to_reset.call_deferred("free")
	# Just so happens that this signal function does the instantiating, 
	# wiring up and everything we need to restart a level
	_on_level_selected(level_path)
	get_tree().paused = false
