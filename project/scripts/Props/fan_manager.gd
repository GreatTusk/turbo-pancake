class_name FanManager
extends Node

# WAIT what if we manage collision layers instead?
const FAN_IMPULSE: float = 12.0
var one_fan_colliding: bool = false
var current_fan_rotation: float
var fan_collision_matrix: Array[bool] = []
signal fan_collided(velocity_applied: Vector2)

func _ready() -> void:
	var fans_size := self.get_child_count() 
	# Initializes each element to false
	self.fan_collision_matrix.resize(fans_size)
	for i in range(0, fans_size):
		var fan := self.get_child(i) as Fan
		fan.own_index = i
		fan.fan_collided.connect(_on_fan_collided)
		fan.deactivated.connect(_on_fan_area_exited)
	self.set_physics_process(false)

func _physics_process(_delta: float) -> void:
	for val in fan_collision_matrix:
		if val:
			# TODO: Tweak this
			var impulse := Vector2.UP.rotated(current_fan_rotation) * FAN_IMPULSE
			impulse.x *= 2
			fan_collided.emit(impulse)
			return
	self.set_physics_process(false)

func _on_fan_collided(rotation: float, index: int) -> void:
	current_fan_rotation = rotation
	fan_collision_matrix[index] = true
	self.set_physics_process(true)

func _on_fan_area_exited(index: int) -> void:
	fan_collision_matrix[index] = false
