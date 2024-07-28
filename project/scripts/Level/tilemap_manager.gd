class_name TileMapManager
extends TileMap

const TILE_OFFSET: int = 25
const SPECIAL_EFFECT_LAYER: int = 1

signal tile_effect_response(modifier: float)

func _on_request_tile_effect(player_pos: Vector2) -> void:
	if get_layers_count() > 1:
		var modifier: float = 1.0
		var current_tile: Vector2i = local_to_map(player_pos)
		current_tile.y += TILE_OFFSET
		var data := get_cell_tile_data(SPECIAL_EFFECT_LAYER, current_tile)
		if data:
			modifier = data.get_custom_data("movement_modifier")
		# Emit a signal back to the player with the modifier value
		self.tile_effect_response.emit(modifier)
