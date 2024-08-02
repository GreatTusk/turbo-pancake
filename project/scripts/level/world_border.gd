extends Area2D

signal kill_player

func _on_body_entered(_body: PlayableCharacter) -> void:
	kill_player.emit()
