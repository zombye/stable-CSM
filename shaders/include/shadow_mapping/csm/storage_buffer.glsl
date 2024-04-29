#if !defined INCLUDE_SHADOW_MAPPING_CSM_STORAGE_BUFFER
#define INCLUDE_SHADOW_MAPPING_CSM_STORAGE_BUFFER

layout (binding = 0) buffer csm_buffer {
	vec3 cascade_projection_scale[CSM_CASCADES];
	vec3 cascade_projection_offset[CSM_CASCADES];
	vec3 cascade_projection_scale_nomargin[CSM_CASCADES];
	vec3 cascade_projection_offset_nomargin[CSM_CASCADES];
	vec2 cascade_pixel_offset[CSM_CASCADES]; // Tracks pixel grid offset to maintain high stability
} csm;

#endif
