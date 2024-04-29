#if !defined INCLUDE_SHADOW_MAPPING_CSM_SELECT_CASCADE
#define INCLUDE_SHADOW_MAPPING_CSM_SELECT_CASCADE

#include "/include/shadow_mapping/csm/storage_buffer.glsl"

#ifdef CSM_VISUALIZE_CASCADES
	uint picked_cascade = uint(CSM_CASCADES);
#endif

// Due to how it works, it also computes `position_shadow_ndc` in the process.
uint csm_select_cascade(vec3 position_shadow_view, out vec3 position_shadow_ndc) {
	uint cascade = 0u;
	for (cascade; cascade < CSM_CASCADES; ++cascade) {
		position_shadow_ndc.xy = csm.cascade_projection_scale[cascade].xy * position_shadow_view.xy + csm.cascade_projection_offset[cascade].xy;

		vec2 margin_ndc = CSM_CASCADE_MARGIN_BLOCKS * csm.cascade_projection_scale[cascade].xy + 2.0 * CSM_CASCADE_MARGIN_PIXELS / shadowMapResolution;
		if (all(greaterThan(position_shadow_ndc.xy, -1.0 + margin_ndc)) && all(lessThan(position_shadow_ndc.xy, 1.0 - margin_ndc))) {
			position_shadow_ndc.z = csm.cascade_projection_scale[cascade].z * position_shadow_view.z + csm.cascade_projection_offset[cascade].z;
			break;
		}
	}

	#ifdef CSM_VISUALIZE_CASCADES
		picked_cascade = cascade;
	#endif

	return cascade;
}

#endif
