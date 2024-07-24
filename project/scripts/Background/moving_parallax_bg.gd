extends ParallaxBackground

@export var scroll_speed: float = 5.0

func _process(delta: float) -> void:
	self.scroll_base_offset.x -= scroll_speed * delta
