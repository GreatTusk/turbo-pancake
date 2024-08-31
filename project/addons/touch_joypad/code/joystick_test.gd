class_name VirtualJoystick
extends Node2D

@export var deadzone: float = 15.0
@export var touchscreen_only := true

@onready var knob: TouchScreenButton = $Knob
@onready var knob_texture: Sprite2D = $Knob/KnobTexture
@onready var button_radius: float = (knob.shape as CircleShape2D).radius

const RETURN_SPEED: float = 50.0
const X_DIRECTION_THRESHOLD: float = 0.35

var pressing := false
var max_length: float = 50.0
var y_event := InputEventAction.new()
var x_event := InputEventAction.new()


func _ready() -> void:
	knob.pressed.connect(func() -> void: pressing = true)
	knob.released.connect(func() -> void: pressing = false)
	max_length *= self.scale.x

func _process(delta: float) -> void:
	parse_input(calculate_direction())
	if pressing:
		handle_knob()
	else:
		# Return the knob to its position
		knob_texture.global_position = knob_texture.global_position.lerp(self.global_position, delta * RETURN_SPEED)
		x_event.pressed = false
		y_event.pressed = false


func handle_knob() -> void:
	# FIXME
	var mouse_pos: Vector2 = get_global_mouse_position()
	# This is not a fix
	if mouse_pos.x < DisplayServer.screen_get_size().x / 2.0:
		var direction: Vector2 = mouse_pos - self.global_position
		
		# Calculates the distance between the mouse position and the joystick's center
		if direction.length() <= max_length:
			# If the mouse is within limits, the knob is moved to that position
			knob_texture.global_position = mouse_pos
		else:
			# If it is further away, calculate where it should be placed
			direction = direction.normalized() * max_length
			knob_texture.global_position = self.global_position + direction


func calculate_direction() -> Vector2:
	var direction: Vector2 = knob_texture.global_position - self.global_position
	return Vector2.ZERO if direction.length() < deadzone else direction.normalized()


func parse_input(direction: Vector2) -> void:
	# Register left or right only when direction.x > 0.35.
	# This means that direction.y will only be registered when over abs(93~)
	if abs(direction.x) > X_DIRECTION_THRESHOLD:
		x_event.pressed = true
		x_event.action = &"move_left" if direction.x < 0 else &"move_right"
		Input.parse_input_event(x_event)
	elif direction.y != 0:
		# Only look up or move down if the condition above was false AND direction.y != 0
		y_event.pressed = true
		y_event.action = &"move_down" if direction.y > 0 else &"look_up"
		Input.parse_input_event(y_event)
