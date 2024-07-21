extends CanvasLayer

@onready var level_modal := $LevelModal as LevelModal

func _on_return_button_pressed() -> void:
	level_modal.visible = true
	get_tree().paused = true
