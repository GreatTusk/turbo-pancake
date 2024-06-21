extends Node2D

@export var fruit: String = "Apple"
@onready var score_label: Label

func _ready():
	score_label = get_node("../../CanvasLayer/Score")
	get_node("AnimatedSprite2D").play(fruit)

func _on_area_2d_body_entered(body: Node2D):
	var voice_lines = body.get_node("VoiceLines/Find")
	score_label.set_text(str(int(score_label.get_text()) + 100))
	var line = voice_lines.get_child(randi_range(0, voice_lines.get_child_count() -1))
	line.play()
	$AnimatedSprite2D.play("collected")
	await $AnimatedSprite2D.animation_finished
	queue_free()
