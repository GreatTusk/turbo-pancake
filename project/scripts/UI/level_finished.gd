class_name LevelFinished
extends Control

signal level_restarted
signal level_selector_pressed


func _on_restart_level_pressed() -> void:
	level_restarted.emit()

func _on_to_level_selector_pressed() -> void:
	level_selector_pressed.emit()
