class_name FloatingPlatform extends StaticBody2D

func _on_fan_body_entered(body: CharacterBody2D):
	body.die()
