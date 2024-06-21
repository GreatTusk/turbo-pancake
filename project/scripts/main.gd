extends Node2D

var respawn_pos: Vector2 = Vector2(-24, 259)

func set_respawn_pos(pos: Vector2):
	respawn_pos = pos

func get_respawn_pos() -> Vector2:
	return respawn_pos
