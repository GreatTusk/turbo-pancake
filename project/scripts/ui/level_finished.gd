class_name LevelFinished
extends Control

@onready var previous_level := $Modal/HBoxContainer/PreviousLevel as TextureButton
@onready var next_level := $Modal/HBoxContainer/NextLevel as TextureButton

signal level_restarted
signal level_selector_pressed
signal next_level_pressed
signal previous_level_pressed

func _ready() -> void:
	previous_level.disabled = Singleton.current_level == 1
	next_level.disabled = Singleton.current_level == Singleton.max_level_count

func _on_restart_level_pressed() -> void:
	level_restarted.emit()

func _on_to_level_selector_pressed() -> void:
	level_selector_pressed.emit()

func _on_next_level_pressed() -> void:
	next_level_pressed.emit()

func _on_previous_level_button_down() -> void:
	previous_level_pressed.emit()
	
