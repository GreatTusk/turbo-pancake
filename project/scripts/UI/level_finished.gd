class_name LevelFinished
extends Control

@onready var previous_level := $Modal/HBoxContainer/PreviousLevel as TextureButton
@onready var next_level := $Modal/HBoxContainer/NextLevel as TextureButton

signal level_restarted
signal level_selector_pressed

var current_level: int

func _ready():
	previous_level.disabled = current_level == 1

func _on_restart_level_pressed() -> void:
	level_restarted.emit()

func _on_to_level_selector_pressed() -> void:
	level_selector_pressed.emit()
