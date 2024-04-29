#if !defined INCLUDE_SHADOW_MAPPING_SHADOW_MAPPING
#define INCLUDE_SHADOW_MAPPING_SHADOW_MAPPING

#ifdef CSM
	#include "/include/shadow_mapping/csm/storage_buffer.glsl"
	#include "/include/shadow_mapping/csm/tile_position.glsl"
	#include "/include/shadow_mapping/csm/select_cascade.glsl"
#else
	#include "/include/shadow_mapping/distortion.glsl"
#endif

#include "/include/shadow_mapping/depth_bias.glsl"

float shadow_mapping(vec3 position_scene) {
	vec3 position_shadow_view = mat3(shadowModelView) * position_scene + shadowModelView[3].xyz;

	#ifdef CSM
		vec3 position_shadow_ndc;
		uint cascade = csm_select_cascade(position_shadow_view, position_shadow_ndc);
		if (cascade >= CSM_CASCADES) { return 1.0; }

		vec3 position_shadow_coordinate = position_shadow_ndc * 0.5 + 0.5;
		position_shadow_coordinate.xy = position_shadow_coordinate.xy * 0.5 + cascade_tile_position(cascade);

		mat2 view_to_uv_transform_jacobian = 0.25 * mat2(csm.cascade_projection_scale[cascade].x, 0.0, 0.0, csm.cascade_projection_scale[cascade].y);
	#else
		vec3 position_shadow_ndc = vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z) * position_shadow_view + shadowProjection[3].xyz;
		vec3 position_shadow_ndc_distorted = vec3(distort_shadow_ndc(position_shadow_ndc.xy), position_shadow_ndc.z);
		mat2 distort_jacobian = distort_shadow_ndc_jacobian(position_shadow_ndc.xy);

		vec3 position_shadow_coordinate = position_shadow_ndc_distorted * 0.5 + 0.5;

		//mat2 view_to_uv_transform_jacobian = 0.5 * distort_jacobian * mat2(shadowProjection);
		mat2 view_to_uv_transform_jacobian = 0.5 * distort_jacobian * mat2(shadowProjection[0].x, 0.0, 0.0, shadowProjection[1].y);
	#endif

	return texture(shadowtex1, position_shadow_coordinate).x;
}

float shadow_mapping(vec3 position_scene, vec3 geometric_normal_scene) {
	vec3 position_shadow_view = mat3(shadowModelView) * position_scene + shadowModelView[3].xyz;

	#ifdef CSM
		vec3 position_shadow_ndc;
		uint cascade = csm_select_cascade(position_shadow_view, position_shadow_ndc);
		if (cascade >= CSM_CASCADES) { return 1.0; }

		vec3 position_shadow_coordinate = position_shadow_ndc * 0.5 + 0.5;
		position_shadow_coordinate.xy = position_shadow_coordinate.xy * 0.5 + cascade_tile_position(cascade);

		mat2 view_to_uv_transform_jacobian = 0.25 * mat2(csm.cascade_projection_scale[cascade].x, 0.0, 0.0, csm.cascade_projection_scale[cascade].y);
	#else
		vec3 position_shadow_ndc = vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z) * position_shadow_view + shadowProjection[3].xyz;
		vec3 position_shadow_ndc_distorted = vec3(distort_shadow_ndc(position_shadow_ndc.xy), position_shadow_ndc.z);
		mat2 distort_jacobian = distort_shadow_ndc_jacobian(position_shadow_ndc.xy);

		vec3 position_shadow_coordinate = position_shadow_ndc_distorted * 0.5 + 0.5;

		//mat2 view_to_uv_transform_jacobian = 0.5 * distort_jacobian * mat2(shadowProjection);
		mat2 view_to_uv_transform_jacobian = 0.5 * distort_jacobian * mat2(shadowProjection[0].x, 0.0, 0.0, shadowProjection[1].y);
	#endif

	//--//

	#ifdef CSM
		//mat2 uv_to_view_transform_jacobian = inverse(view_to_uv_transform_jacobian);
		mat2 uv_to_view_transform_jacobian = mat2(4.0 / csm.cascade_projection_scale[cascade].x, 0.0, 0.0, 4.0 / csm.cascade_projection_scale[cascade].y);
	#else
		mat2 uv_to_view_transform_jacobian = inverse(view_to_uv_transform_jacobian); // we need to use `inverse()` on a mat2 anyway so this is fastest
		//mat2 uv_to_view_transform_jacobian = mat2(shadowProjectionInverse) * inverse(distort_jacobian) * 2.0;
		//mat2 uv_to_view_transform_jacobian = mat2(shadowProjectionInverse[0].x, 0.0, 0.0, shadowProjectionInverse[1].y) * inverse(distort_jacobian) * 2.0;
	#endif

	vec3 geometric_normal_shadow_view = mat3(shadowModelView) * geometric_normal_scene;

	#ifdef CSM
		vec2 geometric_z_slope_shadow_uv = (-0.5 * csm.cascade_projection_scale[cascade].z / geometric_normal_shadow_view.z) * (geometric_normal_shadow_view.xy * uv_to_view_transform_jacobian);
	#else
		/* Unoptimized reference
		vec3 geometric_normal_shadow_ndc = transpose(inverse(mat3(shadowProjection))) * geometric_normal_shadow_view;
		vec3 geometric_normal_shadow_ndc_distorted = vec3(transpose(inverse(distort_jacobian)) * geometric_normal_shadow_ndc.xy, geometric_normal_shadow_ndc.z);
		vec3 geometric_normal_shadow_uv = transpose(inverse(mat3(0.5, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.5))) * geometric_normal_shadow_ndc_distorted;

		vec2 geometric_z_slope_shadow_uv = -geometric_normal_shadow_uv.xy / geometric_normal_shadow_uv.z;
		/*/
		vec2 geometric_z_slope_shadow_uv = (-0.5 * shadowProjection[2].z / geometric_normal_shadow_view.z) * (geometric_normal_shadow_view.xy * uv_to_view_transform_jacobian);
		//*/
	#endif

	// Apply depth bias to reference Z
	// TODO: Allow biasing along normal vector
	float bias_shadow_view_z = shadow_mapping_depth_bias(geometric_normal_shadow_view, uv_to_view_transform_jacobian);
	#ifdef CSM
		float bias_shadow_ndc_z = csm.cascade_projection_scale[cascade].z * bias_shadow_view_z;
	#else
		float bias_shadow_ndc_z = shadowProjection[2].z * bias_shadow_view_z;
	#endif
	float bias_shadow_coordinate_z = 0.5 * bias_shadow_ndc_z;
	position_shadow_coordinate.z += bias_shadow_coordinate_z;

	#ifndef CSM
		// Add extra bias for distortion curvature
		position_shadow_coordinate.z += shadowProjection[2].z * 0.01;
	#endif

	//--//

	return texture(shadowtex1, position_shadow_coordinate).x;
}

#endif
