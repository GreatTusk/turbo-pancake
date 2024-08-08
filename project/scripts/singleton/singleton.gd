extends Node

var current_level: int
var max_level_count: int

func get_children_of_type(node: Node, child_type: Variant, recursive := false) -> Array:
	var list := []
	for i in range(node.get_child_count()):
		var child: Node = node.get_child(i)
		if is_instance_of(child, child_type):
			list.append(child)
		if recursive:
			list += get_children_of_type(child, child_type, recursive)
	return list

func reajust_raycast_target(raycast: RayCast2D) -> void:
	var origin: Vector2 = raycast.global_position
	var collision_point: Vector2 = raycast.get_collision_point()
	var distance_vector: Vector2 = origin.direction_to(collision_point) * origin.distance_to(collision_point)

	# Adjust target_position based on the direction of the raycast
	if raycast.target_position.x < 0:
		distance_vector.x *= -1
	if raycast.target_position.y < 0:
		distance_vector.y *= -1

	raycast.target_position = distance_vector
