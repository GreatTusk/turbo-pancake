extends Node2D
@export var auto_scroll: bool = false
@onready var cave := $Cave as ParallaxBackground

func _physics_process(delta):
	if auto_scroll:
		cave.scroll_base_offset.x -= 40 * delta
