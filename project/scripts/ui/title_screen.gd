class_name TitleScreen
extends Control

signal level_selector_pressed
signal settings_pressed

func _on_settings_pressed() -> void:
	settings_pressed.emit()

func _on_levels_pressed() -> void:
	level_selector_pressed.emit()

func _on_achievements_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	get_tree().quit()
