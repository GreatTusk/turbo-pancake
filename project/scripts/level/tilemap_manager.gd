class_name SpecialTileMapLayer
extends TileMapLayer

const TILE_OFFSET: int = 25

signal tile_effect_response(modifier: float)
signal particle_change_response(particle_index: int)

func _on_request_tile_effect(player_pos: Vector2, particle_index: int) -> void:
	var current_tile: Vector2i = local_to_map(player_pos)
	current_tile.y += TILE_OFFSET
	var data := get_cell_tile_data(current_tile)
	# All SpecialTileMapLayers must have tile data!
	assert(data)
	var modifier: float = data.get_custom_data("movement_modifier")
	var tile_particle_index: int = data.get_custom_data("particle")
	# Emit a signal back to the player with the modifier value
	self.tile_effect_response.emit(modifier)
	if particle_index != tile_particle_index:
		particle_change_response.emit(tile_particle_index)
