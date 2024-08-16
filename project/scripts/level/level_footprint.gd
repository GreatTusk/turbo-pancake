class_name Level
extends Node2D

# The camera values here must be applied to the player
@export_group("Camera settings")
@export var left_limit: int = -10000000
@export var top_limit: int = -10000000
@export var right_limit: int = 10000000
@export var bottom_limit: int = 10000000
@export var tilemap_player_offset: Vector2i


func _on_level_finished() -> void:
	var bgm := $BGM
	if bgm:
		bgm.queue_free()
