extends CanvasLayer

@onready var title_screen := $TitleScreen as TitleScreen
@onready var level_selector := $LevelSelector as LevelSelector

func _ready() -> void:
	#if visible on the tree: level_selector.visible = false
	title_screen.level_selector_pressed.connect(_switch_to_level_selector)
	level_selector.back_to_title_screen.connect(_switch_to_title_screen)

func _switch_to_level_selector() -> void:
	title_screen.visible = false
	level_selector.visible = true
	
func _switch_to_title_screen() -> void:
	level_selector.visible = false
	title_screen.visible = true
