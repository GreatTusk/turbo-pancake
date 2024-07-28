extends ParallaxBackground

@export var scroll_speed: float = 5.0
@export var scroll: bool = true

func _ready() -> void:
	self.set_process(scroll)

func _process(delta: float) -> void:
	self.scroll_base_offset.x -= scroll_speed * delta
