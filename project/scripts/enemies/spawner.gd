class_name Spawner
extends Marker2D

@onready var spawn_rate: Timer = $SpawnRate
@onready var death_timer: Timer = $DeathTimer

@export var enemy: PackedScene

var counter: int = 0
var player: PlayableCharacter:
	set = _on_player_set

func _on_spawn_rate_timeout() -> void:
	var enemy := enemy.instantiate() as JumpableEnemy
	enemy.enemy_jumped_on.connect(player._on_enemy_jumped)
	var personal_timer := death_timer.duplicate() 
	enemy.add_child(personal_timer)
	personal_timer.timeout.connect(func(): 
		#(get_parent() as JumpableEnemy).die()
		get_parent().queue_free()
		print("die")
		)
	# TODO: Randomize spawn
	var random_pos: Vector2 = self.global_position
	random_pos.y = randf_range(random_pos.y - 20.0, random_pos.y + 20.0)
	enemy.global_position = random_pos
	get_parent().add_child(enemy)
	
func _on_player_set(playable_char: PlayableCharacter) -> void:
	player = playable_char
	spawn_rate.autostart = true
