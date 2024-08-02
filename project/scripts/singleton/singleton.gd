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
