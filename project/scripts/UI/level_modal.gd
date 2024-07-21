class_name LevelModal
extends Control

signal level_restarted
signal level_selector_pressed

func unpause() -> void:
	self.visible = false
	get_tree().paused = false

func _on_cancel_pressed() -> void:
	unpause()

func _on_restart_level_pressed() -> void:
	level_restarted.emit()

func _on_to_level_selector_pressed() -> void:
	level_selector_pressed.emit()
