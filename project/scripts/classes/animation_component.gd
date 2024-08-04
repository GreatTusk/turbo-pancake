class_name AnimationComponent
extends Node

@export_group("Options")
@export var from_center: bool = false
@export var parallel: bool = true
@export var properties: Array[String] = [
	"scale",
	"position",
	"rotation",
	"size",
	"self_modulate"
]


@export_group("Hover Settings")
@export var hover_time: float = 0.1
@export var hover_transition: Tween.TransitionType
@export var hover_easing: Tween.EaseType
@export var hover_position := Vector2.ZERO
@export var hover_scale := Vector2(1.0, 1.0)
@export var hover_rotation: float = 0
@export var hover_size := Vector2.ZERO
@export var hover_modulate := Color.WHITE


var target: Control
var initial_values: Dictionary
var on_hover_values: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_parent()
	call_deferred("setup")

func setup() -> void:
	if from_center:
		target.pivot_offset = target.size / 2.0
		
	initial_values = {
		"scale": target.scale,
		"position": target.position,
		"rotation": target.rotation,
		"size": target.size,
		"self_modulate": target.self_modulate,
	}
	
	on_hover_values = {
		"scale": hover_scale,
		"position": hover_position,
		"rotation": target.rotation + deg_to_rad(hover_rotation),
		"size": target.size + hover_size,
		"self_modulate": hover_modulate,
	}
	
	target.mouse_entered.connect(_on_mouse_entered.bind(on_hover_values))
	target.mouse_exited.connect(_on_mouse_exited.bind(initial_values))

func _on_mouse_entered(values: Dictionary) -> void:
	add_tween.call_deferred(values)
	#await target.mouse_entered
	
func _on_mouse_exited(values: Dictionary) -> void:
	add_tween.call_deferred(values)
	#await target.
	
func add_tween(values: Dictionary) -> void:
	var tween := get_tree().create_tween().bind_node(target)
	tween.set_parallel(parallel)
	for property in properties:
		(tween.tween_property(target, property, values[property], hover_time)
		.set_trans(hover_transition)
		.set_ease(hover_easing))
