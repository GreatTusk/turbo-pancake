extends RayCast2D

signal collided
#signal collided(collider: Node2D)
var last_collider: Node2D

func _physics_process(_delta:float) -> void:
	if not is_colliding():
		last_collider = null
		return
	var found_collider: Node2D = get_collider()
	if found_collider != last_collider:
		last_collider = found_collider
		emit_signal("collided")
