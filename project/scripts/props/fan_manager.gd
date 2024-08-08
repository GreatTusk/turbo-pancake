class_name FanManager
extends Node

const FAN_IMPULSE: float = 12.0
var one_fan_colliding: bool = false
var current_fan_rotation: float
var fan_collision_bitmap: BitMap
signal fan_collided(velocity_applied: Vector2)

func _ready() -> void:
	var fans_size := self.get_child_count() 
	# Initialize the bitmap to the size of the number of fans
	fan_collision_bitmap = BitMap.new()
	fan_collision_bitmap.create(Vector2i(fans_size, 1))
	for i in fans_size:
		var fan := self.get_child(i) as Fan
		fan.own_index = i
		fan.fan_collided.connect(_on_fan_collided)
		fan.deactivated.connect(_on_fan_area_exited)
	self.set_physics_process(false)

func _physics_process(_delta: float) -> void:
	for i in fan_collision_bitmap.get_size().x:
		if fan_collision_bitmap.get_bit(i, 0):
			# TODO: Tweak this
			var impulse := Vector2.UP.rotated(current_fan_rotation) * FAN_IMPULSE
			impulse.x *= 2
			fan_collided.emit(impulse)
			return
	self.set_physics_process(false)

func _on_fan_collided(rotation: float, index: int) -> void:
	current_fan_rotation = rotation
	fan_collision_bitmap.set_bit(index, 0, true)
	self.set_physics_process(true)

func _on_fan_area_exited(index: int) -> void:
	fan_collision_bitmap.set_bit(index, 0, false)
