class_name LevelModal
extends Control

signal level_restarted
signal level_selector_pressed
signal audio_settings_pressed

func _on_restart_level_pressed() -> void:
	level_restarted.emit()

func _on_to_level_selector_pressed() -> void:
	level_selector_pressed.emit()

func _on_volume_manager_pressed() -> void:
	audio_settings_pressed.emit()
