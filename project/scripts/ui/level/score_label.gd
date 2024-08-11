extends Label

func _on_fruit_collected(score: int) -> void:
	self.set_text(str(int(self.get_text()) + score));
