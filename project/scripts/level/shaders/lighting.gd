class_name Lighting
extends ColorRect

var get_light_positions: Callable
var previous_viewport_size: Vector2

func _ready() -> void:
	self.set_process(false)
	previous_viewport_size = get_viewport_rect().size
	
func _process(_delta: float) -> void:
	var current_viewport_size: Vector2 = DisplayServer.window_get_size()
	var shader_material: ShaderMaterial = self.material
	# Check if the viewport size has changed
	if current_viewport_size != previous_viewport_size:
		# Scale the light parameters
		var scale_factor: float = current_viewport_size.x / previous_viewport_size.x
		shader_material.set_shader_parameter(&"light_radius", shader_material.get_shader_parameter(&"light_radius") * scale_factor)
		shader_material.set_shader_parameter(&"band_radius", shader_material.get_shader_parameter(&"band_radius") * scale_factor)
		previous_viewport_size = current_viewport_size
	
	var light_positions: PackedVector2Array = get_light_positions.call()
	var viewport_transform: Transform2D = get_viewport_transform()
	
	# Convert light positions to screen space
	var screen_space_positions: PackedVector2Array = []
	for light_pos: Vector2 in light_positions:
		screen_space_positions.append(viewport_transform.basis_xform(light_pos))
	
	# Update shader parameters
	(self.material as ShaderMaterial).set_shader_parameter("number_of_lights", screen_space_positions.size())
	(self.material as ShaderMaterial).set_shader_parameter("lights", screen_space_positions)
