extends Label

func _on_state_changed(state: StringName) -> void:
	self.set_text(state)
