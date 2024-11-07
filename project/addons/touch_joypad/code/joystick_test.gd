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

var touch_index := -1 # Track the touch affecting the joystick
var is_dragging := false # Track if the user is dragging the knob


func _ready() -> void:
	max_length *= self.scale.x

func _process(delta: float) -> void:
	parse_input()
	
	#if pressing:
		#handle_knob()
	#else:
	if touch_index == -1:
		# Return the knob to its position
		knob_texture.global_position = knob_texture.global_position.lerp(self.global_position, delta * RETURN_SPEED)
		x_event.pressed = false
		y_event.pressed = false

func _input(event: InputEvent) -> void:
	#print(event)
	#if event is InputEventScreenTouch:
		##print(event.position.distance_to(self.global_position))
		#if event.index == 0:
			## Touch event is within self.area
			#pressing = event.position.distance_to(self.global_position) <= button_radius
			#if !event.pressed:
				#pressing = falseh affecting the joystick

	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			# Check if the touch is within the joystick area
			if event.position.distance_to(self.global_position) <= button_radius:
				touch_index = event.index
				pressing = true
				is_dragging = false
				# Move the knob to the touched position immediately (handling a tap)
				handle_knob(event.position)
		elif !event.pressed and event.index == touch_index:
			# When the touch ends, reset the state
			pressing = false
			touch_index = -1
			#is_dragging = false

	elif event is InputEventScreenDrag and event.index == touch_index:
		# Handle joystick dragging with the specific touch
		is_dragging = true
		handle_knob(event.position)


#func handle_knob() -> void:
	## FIXME
	#var mouse_pos: Vector2 = get_global_mouse_position()
	## This is not a fix
	#if mouse_pos.x < DisplayServer.window_get_size().x / 2.0:
		#print(DisplayServer.window_get_size())
		#var direction: Vector2 = mouse_pos - self.global_position
		#
		## Calculates the distance between the mouse position and the joystick's center
		#if direction.length() <= max_length:
			## If the mouse is within limits, the knob is moved to that position
			#knob_texture.global_position = mouse_pos
		#else:
			## If it is further away, calculate where it should be placed
			#direction = direction.normalized() * max_length
			#knob_texture.global_position = self.global_position + direction

func handle_knob(pos: Vector2) -> void:
	var direction: Vector2 = pos - self.global_position

	if direction.length() <= max_length:
		knob_texture.global_position = pos
	else:
		direction = direction.normalized() * max_length
		knob_texture.global_position = self.global_position + direction

func parse_input() -> void:
	var direction: Vector2 = knob_texture.global_position - self.global_position
	direction = Vector2.ZERO if direction.length() < deadzone else direction.normalized()
	
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
