extends Label

func _on_fruit_collected(_fruit: StringName) -> void:
	self.set_text(str(int(self.get_text()) + 100));
