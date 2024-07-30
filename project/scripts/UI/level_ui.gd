class_name LevelUI
extends CanvasLayer

@onready var level_modal := $LevelModal as LevelModal
@onready var config_screen := $ConfigScreen as ConfigScreen
@onready var mobile_controls := $MobileControls as Node2D

func _ready() -> void:
	level_modal.audio_settings_pressed.connect(_on_audio_settings_pressed)
	(level_modal.get_node("Modal/Cancel") as TextureButton).pressed.connect(_exit_menu_pressed)
func _on_audio_settings_pressed() -> void:
	config_screen.show()

func _on_menu_button_pressed() -> void:
	mobile_controls.hide()
	level_modal.show()
	get_tree().paused = true

func _exit_menu_pressed() -> void:
	mobile_controls.show()
	level_modal.hide()
	get_tree().paused = false
