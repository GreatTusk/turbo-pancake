class_name SpecialTileMapLayer
extends TileMapLayer

signal particle_change_response
signal walking_sfx_response
signal mov_response


func _on_request_tile_effect(player_pos: Vector2, tile_offset: Vector2i, tile_data: TileDataStruct) -> void:
	var current_tile: Vector2i = local_to_map(player_pos)
	var data: TileData = get_cell_tile_data(
		Vector2i(current_tile.x + tile_offset.x, current_tile.y + tile_offset.y))

	if data:
		var mov_modifier: float = data.get_custom_data("movement_modifier")
		if mov_modifier != tile_data.movement_modifier:
			tile_data.fall_through = tile_data.movement_modifier
			mov_response.emit()
		
		var tile_particle_color: Color = data.get_custom_data("particle_color")
		if tile_data.particle_color != tile_particle_color:
			tile_data.particle_color = tile_particle_color
			particle_change_response.emit()
		
		# no need to check
		tile_data.fall_through = data.get_custom_data("fall_through")
		
		var walking_sfx_idx: int = data.get_custom_data("walking_sfx_idx")
		if tile_data.walking_sfx_idx != walking_sfx_idx:
			tile_data.walking_sfx_idx = walking_sfx_idx
			walking_sfx_response.emit()
