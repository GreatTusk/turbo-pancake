extends CanvasLayer

@onready var title_screen := $TitleScreen as TitleScreen
@onready var level_selector := $LevelSelector as LevelSelector
@onready var parallax_backgrounds := $ParallaxBackgrounds as BackgroundsManager
@onready var config_screen := $ConfigScreen as ConfigScreen

func _ready() -> void:
	var random_bg: PackedScene = parallax_backgrounds.backgrounds.pick_random()
	self.add_child(random_bg.instantiate())
	title_screen.level_selector_pressed.connect(_switch_to_level_selector)
	title_screen.settings_pressed.connect(_on_settings_pressed)
	level_selector.back_to_title_screen.connect(_switch_to_title_screen)
	
func _switch_to_level_selector() -> void:
	title_screen.hide()
	level_selector.show()
	
func _switch_to_title_screen() -> void:
	level_selector.hide()
	title_screen.show()

func _on_settings_pressed() -> void:
	config_screen.show()
