class_name Level
extends Node2D

# The camera values here must be applied to the player
@export_category("Camera settings")
@export var left_limit: int = -10000000
@export var top_limit: int = -10000000
@export var right_limit: int = 10000000
@export var bottom_limit: int = 10000000
@export_category("")

@onready var cave_parallax_background: Node2D = $CaveParallaxBackground

func _ready() -> void:
	#for i in self.get_children():
		#if i is Parallax2DManager:
			#for j: Parallax2D in i.get_children():
				#j.limit_begin = Vector2(left_limit, top_limit)
				#j.limit_end = Vector2(right_limit, bottom_limit)
			#break
	pass
	
func _on_level_finished() -> void:
	var bgm := $BGM
	if bgm:
		bgm.queue_free()
