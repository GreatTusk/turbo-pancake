extends Node2D

@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D

signal level_finished

func _ready():
	var main = self.get_node("../../../Main")
	self.connect("level_finished", Callable(main, "_on_level_finished"))
	
func _on_area_2d_body_entered(body):
	emit_signal("level_finished")
	animated_sprite_2d.play("idle")
	collision_shape_2d.call_deferred("set_disabled", true)

	
	
