class_name Turtle
extends JumpableEnemy

@onready var spikes_hitbox: CollisionPolygon2D = $SpikesHitbox
@onready var hitbox: CollisionPolygon2D = $Hitbox

func _ready() -> void:
	# Initialize vars from super class
	interaction_timer = $Timers/InteractionTimer
	animated_sprite = $Sprites
	hurt_sfx = $SFX/Hurt
	death_sfx = $SFX/Death
	animated_sprite.animation_finished.connect(_on_animation_finished)
	($Timers/SpikesTimer as Timer).start()
	self.velocity = initial_velocity
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _on_spikes_timer_timeout() -> void:
	animated_sprite.play(&"spikes_out" if jumpable else &"spikes_in")
	
func _on_animation_finished() -> void:
	match animated_sprite.animation:
		&"spikes_out":
			animated_sprite.play(&"idle_spike")
			spikes_hitbox.disabled = false
			hitbox.disabled = true
		&"spikes_in":
			animated_sprite.play(&"idle")
			hitbox.disabled = false
			spikes_hitbox.disabled = true
		&"hit", &"die":
			super._on_animation_finished()
	jumpable = animated_sprite.animation != &"idle_spike"
