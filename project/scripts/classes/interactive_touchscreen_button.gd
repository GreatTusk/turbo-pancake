@icon("res://editor_icons/control_touchscreen_button.svg")

# https://github.com/Mustache-Games/Godot-Interactive-Touchscreen-Button/tree/main
class_name ControlTouchscreenButton
extends TextureButton

const DefaultValues := {
	"expand" : true,
	"ignore_texture_size" : true,
	"stretch_mode" : TextureButton.STRETCH_KEEP_ASPECT_CENTERED,
	"action_mode" : TextureButton.ACTION_MODE_BUTTON_PRESS,
	"focus_mode" : TextureButton.FOCUS_NONE,
}

@export var input_action: StringName
@export var use_default_values := true
@export var touchscreen_only := false

var touch_index := 0
var released := true

func _init() -> void:
	if use_default_values :
		for k: String in DefaultValues.keys() :
			self.set(k, DefaultValues.get(k))
	
	if touchscreen_only and not DisplayServer.is_touchscreen_available() :
		hide()


func press() -> void:
	var event := InputEventAction.new()
	event.action = input_action
	event.pressed = true
	Input.parse_input_event(event)
	released = false


func release() -> void:
	var event := InputEventAction.new()
	event.action = input_action
	event.pressed = false
	Input.parse_input_event(event)
	released = true


func is_in(pos: Vector2) -> bool:
	print(pos)
	print(range(self.global_position.x, self.global_position.x + self.size.x))
	print(range(self.global_position.y, self.global_position.y + self.size.y))
	return (
		int(pos.x) in range(self.global_position.x, self.global_position.x + self.size.x) &&
		int(pos.y) in range(self.global_position.y, self.global_position.y + self.size.y))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch :
		if event.pressed and is_in(event.position):
			if released:
				touch_index = event.index
			if touch_index == event.index:
				press()
			else:
				release()
		if touch_index == event.index and not event.pressed :
			release()
