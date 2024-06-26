extends Label

func _on_fruit_collected(fruit: StringName):
	self.set_text(str(int(self.get_text()) + 100));
