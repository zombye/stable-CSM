#if !defined INCLUDE_SHADE_SURFACE
#define INCLUDE_SHADE_SURFACE

#include "/include/shadow_mapping/shadow_mapping.glsl"

vec3 basic_shading(
	vec3 base_color,
	vec3 position_view,
	vec3 normal_view,
	float block_light_level,
	float sky_light_level
) {
	vec3 position_scene = mat3(gbufferModelViewInverse) * position_view + gbufferModelViewInverse[3].xyz;
	vec3 normal_scene = mat3(gbufferModelViewInverse) * normal_view;
	float shadows = shadow_mapping(position_scene, normal_scene);

	#if defined CSM && defined CSM_VISUALIZE_CASCADES
		base_color = vec3[5](vec3(1.0, 1.0, 1.0), vec3(0.0, 1.0, 1.0), vec3(0.0, 1.0, 0.0), vec3(1.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0))[picked_cascade];
	#endif

	sky_light_level *= mix(13.0 / 15.0, 1.0, shadows);
	vec2 lightmap_texture_coordinate = (vec2(block_light_level, sky_light_level) + 0.5) / 16.0;
	vec3 lightmap_sample = texture(lightmap, lightmap_texture_coordinate).rgb;

	return lightmap_sample * base_color;
}

#endif
