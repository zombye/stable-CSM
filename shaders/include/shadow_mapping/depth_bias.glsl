#if !defined INCLUDE_SHADOW_MAPPING_DEPTH_BIAS
#define INCLUDE_SHADOW_MAPPING_DEPTH_BIAS

float shadow_mapping_depth_bias(vec3 geometric_normal_shadow_view, mat2 shadow_coordinate_to_shadow_view_transform_jacobian) {
	vec2 geometric_z_slope_shadow_view = -geometric_normal_shadow_view.xy / geometric_normal_shadow_view.z;

	// Approximate pixel footprint as a parallelogram, represented using a matrix.
	// As the transformation should have low curvature, and a transformation with curvature requires additional bias regardless since the curvature isn't captured during rasterization, this approximation is sufficient.
	/*
	const mat2 pixel_parallelogram_shadow_coordinate = mat2(
		1.0 / float(shadowMapResolution), 0.0,
		0.0, 1.0 / float(shadowMapResolution)
	);
	mat2 pixel_parallelogram_shadow_view = shadow_coordinate_to_shadow_view_transform_jacobian * pixel_parallelogram_shadow_coordinate;
	/*/
	mat2 pixel_parallelogram_shadow_view = shadow_coordinate_to_shadow_view_transform_jacobian / float(shadowMapResolution);
	//*/

	// The "largest" possible deviation from a pixel center that isn't corrected for the surface plane, in pixels.
	// For hardware nearest filtering, this should be 0.5.
	// For hardware bilinear filtering, this should be 1.0.
	// Certain filters doing software comparison can allow this to be 0.
	const float deviation_distance_pixels = 1.0;

	// Pick pixel corner that requires the largest bias
	/* Reference unoptimized version
	vec2 pixel_corner_offset_nn = pixel_parallelogram_shadow_view * vec2(-deviation_distance_pixels,-deviation_distance_pixels);
	vec2 pixel_corner_offset_pn = pixel_parallelogram_shadow_view * vec2( deviation_distance_pixels,-deviation_distance_pixels);
	vec2 pixel_corner_offset_np = pixel_parallelogram_shadow_view * vec2(-deviation_distance_pixels, deviation_distance_pixels);
	vec2 pixel_corner_offset_pp = pixel_parallelogram_shadow_view * vec2( deviation_distance_pixels, deviation_distance_pixels);
	float bias_shadow_view_z = max(
		max(
			dot(pixel_corner_offset_nn, geometric_z_slope_shadow_view),
			dot(pixel_corner_offset_pn, geometric_z_slope_shadow_view)),
		max(
			dot(pixel_corner_offset_np, geometric_z_slope_shadow_view),
			dot(pixel_corner_offset_pp, geometric_z_slope_shadow_view))
	);
	/*/
	vec2 tmp = abs(geometric_z_slope_shadow_view * pixel_parallelogram_shadow_view);
	float bias_shadow_view_z = deviation_distance_pixels * (tmp.x + tmp.y);
	//*/
	return bias_shadow_view_z;
}

#endif
