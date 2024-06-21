extends Node2D

var collider = null

func _process(delta):
	if collider != null:
		collider.velocity.y -= 500 * delta
		
func _on_area_2d_body_entered(body):
	collider = body


func _on_area_2d_body_exited(body):
	collider = null
