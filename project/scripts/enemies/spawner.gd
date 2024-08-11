class_name Spawner
extends Marker2D

@onready var spawn_rate: Timer = $SpawnRate

@export var enemy_scene: PackedScene
@export var spawn_range: float

var counter: int = 0
var player: PlayableCharacter:
	set = _on_player_set
var score_label: Label

func _on_spawn_rate_timeout() -> void:
	var enemy := enemy_scene.instantiate() as JumpableEnemy
	var notifier := VisibleOnScreenNotifier2D.new()
	enemy.add_child(notifier)
	notifier.screen_exited.connect(func() -> void: enemy.queue_free())
	enemy.enemy_jumped_on.connect(player._on_enemy_jumped)
	enemy.enemy_defeated.connect(Callable(score_label, "_on_fruit_collected"))
	
	# Add the enemy to the level
	var random_pos: Vector2 = self.global_position
	random_pos.y = randf_range(random_pos.y - spawn_range, random_pos.y + spawn_range)
	enemy.global_position = random_pos
	get_parent().add_child(enemy)

func _on_player_set(playable_char: PlayableCharacter) -> void:
	player = playable_char
	spawn_rate.start()
