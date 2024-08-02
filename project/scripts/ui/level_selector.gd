class_name LevelSelector
extends Control

@onready var levels_container := $Levels as GridContainer

signal back_to_title_screen
signal level_selected(level_scene_path: String)

const LEVELS_PATH: String = "res://scenes/levels"

func _ready() -> void:
	const icons_path := "res://assets/menu/levels/%s.png"
	var level_count: int = count_files_dir(LEVELS_PATH)
	Singleton.max_level_count = level_count

	for i in range(1, level_count + 1):
		# Create buttons, set some properties
		var level_button := TextureButton.new()
		# Add padding if necessary to match the png's name
		level_button.texture_normal = load(icons_path % ("%02d" % i))
		level_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		level_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		level_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		level_button.custom_minimum_size = Vector2(25.0, 25.0)
		
		# Wire up their pressed signal binding the index to _on_level_button_pressed
		level_button.pressed.connect(_on_level_button_pressed.bind(i))
		levels_container.add_child(level_button)
		
# From https://docs.godotengine.org/en/4.0/classes/class_diraccess.html#diraccess
func count_files_dir(path: String) -> int:
	var dir := DirAccess.open(path)
	var counter: int = 0
	# Dir must NOT be null!
	assert(dir)
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			# Found a file
			counter += 1
		file_name = dir.get_next()
	return counter

func _on_level_button_pressed(level_index: int) -> void:
	# Emit the level's scene path to Main
	Singleton.current_level = level_index
	level_selected.emit((LEVELS_PATH + "/level_%s.tscn") % level_index)

func _on_to_title_screen_pressed()  -> void:
	back_to_title_screen.emit()
