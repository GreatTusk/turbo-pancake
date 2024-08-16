class_name TileDataStruct

var movement_modifier: float
var fall_through: bool
var walking_sfx_idx: int
var particle_color: Color

func setup(mov: float, fall: bool, walking_sfx: int, color: Color) -> void:
	movement_modifier = mov
	fall_through = fall
	walking_sfx_idx = walking_sfx
	particle_color = color
	
