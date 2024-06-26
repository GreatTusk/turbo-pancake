extends RayCast2D

signal first_collision

func _ready() -> void:
	self.connect("first_collision", Callable(self, "_on_first_collision"))

func _physics_process(delta) -> void:
	var collider: Object = self.get_collider()
	if self.is_colliding() && (collider is FloatingPlatform or collider is TileMap):
		emit_signal("first_collision")

func _on_first_collision() -> void:
	reajust_raycast_target(self)
	self.set_collision_mask_value(1, false)
	self.set_physics_process(false)
	
func reajust_raycast_target(raycast: RayCast2D) -> void:
	var origin: Vector2 = raycast.global_position
	var collision_point: Vector2 = raycast.get_collision_point()
	var distance: float = origin.distance_to(collision_point)
	raycast.target_position.y = distance
