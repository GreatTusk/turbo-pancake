class_name VirtualJoystick
extends Node2D

@onready var button: Button = $Button
@onready var knob: Sprite2D = $Knob

@export var deadzone: float = 15.0
@export var maxLength: float = 50
@export var touchscreen_only := true

const RETURN_SPEED: float = 50.0
const X_DIRECTION_THRESHOLD: float = 0.35

var pressing := false
var y_event := InputEventAction.new()
var x_event := InputEventAction.new()


func _ready() -> void:
	button.button_down.connect(func() -> void: pressing = true)
	button.button_up.connect(func() -> void: pressing = false)
	maxLength *= self.scale.x

func _process(delta: float) -> void:
	parse_input(calculate_direction())
	if pressing:
		handle_knob()
	else:
		# Return the knob to its position
		knob.global_position = knob.global_position.lerp(self.global_position, delta * RETURN_SPEED)
		x_event.pressed = false
		y_event.pressed = false


func handle_knob() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = mouse_pos - self.global_position
	
	# Calculates the distance between the mouse position and the joystick's center
	if direction.length() <= maxLength:
		# If the mouse is within limits, the knob is moved to that position
		knob.global_position = mouse_pos
	else:
		# If it is further away, calculate where it should be placed
		direction = direction.normalized() * maxLength
		knob.global_position = self.global_position + direction


func calculate_direction() -> Vector2:
	var direction: Vector2 = knob.global_position - self.global_position
	return Vector2.ZERO if direction.length() < deadzone else direction.normalized()


func parse_input(direction: Vector2) -> void:
	if direction.y != 0:
		y_event.pressed = true
		y_event.action = &"move_down" if direction.y > 0 else &"look_up"
		Input.parse_input_event(y_event)
	
	if abs(direction.x) > X_DIRECTION_THRESHOLD:
		x_event.pressed = true
		x_event.action = &"move_left" if direction.x < 0 else &"move_right"
		Input.parse_input_event(x_event)
