class_name ParticleQueue
extends Node2D

@export var queue_size: int = 2
@export var particle_scene: PackedScene
@export_enum("Normal", "Ice", "Mud", "Sand") var particle_texture: int = 0

const TEXTURES: PackedStringArray = [
	"res://assets/other/dust_particle.png", 
	"res://assets/traps/sand_mud_ice/ice_particle.png",
	"res://assets/traps/sand_mud_ice/mud_particle.png",
	"res://assets/traps/sand_mud_ice/sand_particle.png"] 

var index: int = 0

func _ready() -> void:
	var particle := particle_scene.instantiate() as GPUParticles2D
	particle.texture = load(TEXTURES[particle_texture])
	for _i in range(queue_size):
		self.add_child(particle.duplicate())

func get_next_particle() -> GPUParticles2D:
	return self.get_child(index)

func trigger() -> void:
	get_next_particle().restart()
	index = (index + 1) % queue_size
