class_name Parallax2DManager
extends Node2D

@export var base_speed: float = 5.0
@export var speed_multiplier: float = 1.25
@export var scroll: bool = true
@export var repeat_times: int = 2
@export var follow_viewport: bool = true
@export var ignore_camera_scroll: bool = true

func _ready() -> void:
	assert(get_child_count() > 1)
	var speed := base_speed
	for parallax_2d: Parallax2D in self.get_children():
		parallax_2d.repeat_times = repeat_times
		parallax_2d.follow_viewport = follow_viewport
		parallax_2d.ignore_camera_scroll = ignore_camera_scroll
		if scroll:
			parallax_2d.autoscroll.x = speed
			speed *= speed_multiplier
