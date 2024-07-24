class_name ConfigScreen
extends Control

signal settings_closed

func _on_cancel_pressed() -> void:
	self.hide()
