class_name BlueBird
extends JumpableEnemy


func _ready() -> void:
	# Initialize vars from super class
	interaction_timer = $InteractionTimer
	animated_sprite = $Sprites
	hurt_sfx = $SFX/Hurt
	death_sfx = $SFX/Death
	animated_sprite.animation_finished.connect(_on_animation_finished)
	self.velocity = initial_velocity
	
func _physics_process(delta: float) -> void:
	# Other logic that may be specific to the BlueBird...
	super._physics_process(delta)
	
