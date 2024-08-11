class_name LevelUI
extends CanvasLayer

@onready var level_modal := $LevelModal as LevelModal
@onready var config_screen := $ConfigScreen as ConfigScreen
@onready var mobile_controls: Control = $MobileControls
@onready var hover: AudioStreamPlayer = $SFX/Hover
@onready var confirm: AudioStreamPlayer = $SFX/Confirm
@onready var pause: AudioStreamPlayer = $SFX/Pause
@onready var unpause: AudioStreamPlayer = $SFX/Unpause

func _ready() -> void:
	mobile_controls.visible = Input.get_connected_joypads().size() == 0
	level_modal.audio_settings_pressed.connect(_on_audio_settings_pressed)
	(level_modal.get_node("Modal/Cancel") as TextureButton).pressed.connect(_exit_menu_pressed)
	# Recursive
	for button: BaseButton in Singleton.get_children_of_type(self, BaseButton, true):
		button.mouse_entered.connect(_on_button_action.bind(hover))
		if button.is_in_group("pause"):
			button.pressed.connect(_on_button_action.bind(pause))
		elif button.is_in_group("unpause"):
			button.pressed.connect(_on_button_action.bind(unpause))
		else:
			button.pressed.connect(_on_button_action.bind(confirm))

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

func _on_button_action(sfx: AudioStreamPlayer) -> void:
	sfx.play()
