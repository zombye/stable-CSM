#if !defined INCLUDE_SHADOW_MAPPING_CSM_TILE_POSITION
#define INCLUDE_SHADOW_MAPPING_CSM_TILE_POSITION

vec2 cascade_tile_position(uint cascade) {
	return vec2(
		cascade % 2u,
		cascade / 2u
	) / 2.0;
}

#endif
