extends RayCast2D

signal first_collision

func _ready() -> void:
	first_collision.connect(_on_first_collision)

func _physics_process(_delta: float) -> void:
	var collider: Object = self.get_collider()
	if self.is_colliding() && (collider is FloatingPlatform or collider is TileMap):
		first_collision.emit()

func _on_first_collision() -> void:
	Singleton.reajust_raycast_target(self)
	self.set_collision_mask_value(3, false)
	self.set_collision_mask_value(4, false)
	self.set_physics_process(false)
