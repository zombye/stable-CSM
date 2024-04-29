#if !defined INCLUDE_FOG
#define INCLUDE_FOG

vec3 apply_fog(
	vec3 color,
	vec3 position_view
) {
	#define FOG_SHAPE_SPHERE 0
	#define FOG_SHAPE_CYLINDER 1
	float fog_depth;
	switch (fogShape) {
		case FOG_SHAPE_CYLINDER: {
			vec3 world_oriented_position = mat3(gbufferModelViewInverse) * position_view;
			float dist_xz = length(world_oriented_position.xz);
			float dist_y = abs(world_oriented_position.y);
			fog_depth = max(dist_xz, dist_y);
			break;
		}
		default:
		case FOG_SHAPE_SPHERE: {
			fog_depth = length(position_view);
			break;
		}
	}

	#define FOG_MODE_LINEAR 9729
	#define FOG_MODE_EXP 2048
	#define FOG_MODE_EXP2 2049
	float fog_factor;
	switch (fogMode) {
		case FOG_MODE_LINEAR: {
			fog_factor = clamp((fog_depth - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
			break;
		}
		case FOG_MODE_EXP: {
			fog_factor = exp(-fogDensity * fog_depth);
			break;
		}
		case FOG_MODE_EXP2: {
			fog_factor = exp(-fogDensity * fog_depth * fog_depth);
			break;
		}
		default: {
			fog_factor = 0.0;
			break;
		}
	}

	return mix(color, fogColor, fog_factor);
}

#endif
