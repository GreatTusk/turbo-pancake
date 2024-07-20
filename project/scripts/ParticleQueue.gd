class_name ParticleQueue
extends Node2D

@export var queue_count: int = 2
@export var particle: PackedScene

var index: int = 0

func _ready() -> void:
	for _i in range(queue_count):
		self.add_child(particle.instantiate())

func get_next_particle() -> GPUParticles2D:
	return (self.get_child(index) as GPUParticles2D)

func trigger() -> void:
	get_next_particle().restart()
	index = (index + 1) % queue_count
