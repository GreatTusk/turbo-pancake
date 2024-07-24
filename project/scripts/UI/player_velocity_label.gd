extends Label

func _on_velocity_changed(vel: StringName) -> void:
	self.set_text(vel)
