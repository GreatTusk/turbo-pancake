extends RigidBody2D


func _on_body_entered(body: Node2D):
	$AnimatedSprite2D.play()
	
	
