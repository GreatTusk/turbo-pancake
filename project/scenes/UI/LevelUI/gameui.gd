extends CanvasLayer

@onready var level_modal := $LevelModal as LevelModal
@onready var config_screen := $ConfigScreen as ConfigScreen

func _ready() -> void:
	level_modal.audio_settings_pressed.connect(_on_audio_settings_pressed)

func _on_audio_settings_pressed() -> void:
	config_screen.show()

func _on_return_button_pressed() -> void:
	level_modal.visible = true
	get_tree().paused = true
