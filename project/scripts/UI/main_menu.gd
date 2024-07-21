extends CanvasLayer

@export var level_selector: PackedScene
@onready var title_screen := $TitleScreen as TitleScreen

var selector_scene: LevelSelector

func _ready() -> void:
	title_screen.level_selector_pressed.connect(_switch_to_level_selector)
	selector_scene = level_selector.instantiate()
	selector_scene.visible = false
	selector_scene.back_to_title_screen.connect(_switch_to_title_screen)
	self.add_child(selector_scene)

func _switch_to_level_selector() -> void:
	title_screen.visible = false
	selector_scene.visible = true
	
func _switch_to_title_screen() -> void:
	selector_scene.visible = false
	title_screen.visible = true
