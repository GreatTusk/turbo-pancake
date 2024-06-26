extends AudioStreamPlayer

func _on_finished():
	print("Termine de reproducir la cancion")
	self.play()
