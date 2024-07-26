extends AudioStreamPlayer

func _ready() -> void:
	self.finished.connect(_on_finished)
	
func _on_finished() -> void:
	self.play()
