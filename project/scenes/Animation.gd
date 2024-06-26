extends Label

func _on_animation_changed(animation: StringName) -> void:
	self.set_text(animation)
