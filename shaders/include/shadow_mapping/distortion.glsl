#if !defined INCLUDE_SHADOW_MAPPING_DISTORTION
#define INCLUDE_SHADOW_MAPPING_DISTORTION

// Core functions for distoriton.
// The Jacobian for each is required to account for local properties of the transformation.
// That way things like the depth bias & filter ellipses can account for it.
// Note that this will likely be adjusted in the future.

// Defines the norm used for distortion
// The choice of norm determines the used balance used shadow map area with smoothness
#define DISTORTION_NORM_EUCLIDEAN 0
#define DISTORTION_NORM_POWER 1
#define DISTORTION_NORM DISTORTION_NORM_EUCLIDEAN
#define DISTORTION_NORM_POWER_VALUE 3.0 // 2 matches euclidean, higher values trade smoothness for better area utilization
float distort_norm(vec2 position_shadow_ndc) {
	#if DISTORTION_NORM == DISTORTION_NORM_POWER
		const float p = DISTORTION_NORM_POWER_VALUE;
		position_shadow_ndc = pow(abs(position_shadow_ndc), vec2(p));
		return pow(position_shadow_ndc.x + position_shadow_ndc.y, 1.0 / p);
	#else // DISTORTION_NORM == DISTORTION_NORM_EUCLIDEAN
		return length(position_shadow_ndc);
	#endif
}
// NOTE: This specifically returns a row vector (would use mat2x1 to signal this if GLSL allowed it)
vec2 distort_norm_jacobian(vec2 position_shadow_ndc) {
	#if DISTORTION_NORM == DISTORTION_NORM_POWER
		const float p = DISTORTION_NORM_POWER_VALUE;
		vec2 tmp = pow(abs(position_shadow_ndc), vec2(p));
		return sign(position_shadow_ndc) * pow(tmp.x + tmp.y, 1.0 / p - 1.0) * pow(abs(position_shadow_ndc), vec2(p - 1.0));
	#else // DISTORTION_NORM == DISTORTION_NORM_EUCLIDEAN
		return position_shadow_ndc / length(position_shadow_ndc);
	#endif
}

// Evaluates the distortion "factor"; i.e. how much to scale the position at this "radius".
// This controls how nearby regions are expanded and distant regions are compressed.
// 2 is a theoretical nearly-perfect approach, but accurately evaluating the constants it needs requires the Lambert W function.
// 1 is a simpler method which is close enough to perfect.
// 0 is present strictly for its historical value - it is the first apporoach used by Minecraft shaderpacks, and is still very common. It is quite bad, however.
#define DISTORTION_MODE 1
#define DISTORTION_NEAR_SCALE 16.0
float distort_factor(float radius) {
	#if DISTORTION_MODE == 2
		const float slope = shadowDistance / DISTORTION_NEAR_SCALE;
		const float tmpc = 1.0 + (1.0 - 2.0 * slope + slope * slope) / (-3.0 + 9.0 * slope + 7.3 * slope * slope);
		const float Q = log(slope * (log(tmpc * slope) + log(log(tmpc * slope) + 1.0)) + 1.0);
		return log(slope * Q * radius + 1.0) / (Q * radius);
	#elif DISTORTION_MODE == 1
		const float dist_recip = DISTORTION_NEAR_SCALE / shadowDistance;
		const float add = exp2(dist_recip);
		const float mul = exp2(1.0) - add;

		return 1.0 / log2(mul * radius + add);
	#elif DISTORTION_MODE == 0
		const float dist_recip = DISTORTION_NEAR_SCALE / shadowDistance;
		return 1.0 / (dist_recip + (1.0 - dist_recip) * radius);
	#endif
}
float distort_factor_jacobian(float radius) {
	#if DISTORTION_MODE == 2
		const float slope = shadowDistance / DISTORTION_NEAR_SCALE;
		const float tmpc = 1.0 + (1.0 - 2.0 * slope + slope * slope) / (-3.0 + 9.0 * slope + 7.3 * slope * slope);
		const float Q = log(slope * (log(tmpc * slope) + log(log(tmpc * slope) + 1.0)) + 1.0);

		return (slope * Q * radius / (slope * Q * radius + 1.0) - log(slope * Q * radius + 1.0)) / (Q * radius * radius);
	#elif DISTORTION_MODE == 1
		const float dist_recip = DISTORTION_NEAR_SCALE / shadowDistance;
		const float add = exp2(dist_recip);
		const float mul = exp2(1.0) - add;

		float tmp = mul * radius + add;
		float log2_tmp = log2(tmp);
		return (-mul / log(2.0)) / (log2_tmp * log2_tmp * tmp);
	#elif DISTORTION_MODE == 0
		const float dist_recip = DISTORTION_NEAR_SCALE / shadowDistance;
		return -(1.0 - dist_recip) / pow(dist_recip + (1.0 - dist_recip) * radius, 2.0);
	#endif
}

// Applies distortion to shadow NDC space.
// Distortion is only applied to the X and Y components.
vec2 distort_shadow_ndc(vec2 position_shadow_ndc_xy) {
	return position_shadow_ndc_xy * distort_factor(distort_norm(position_shadow_ndc_xy));
}
mat2 distort_shadow_ndc_jacobian(vec2 position_shadow_ndc_xy) {
	float norm            = distort_norm(position_shadow_ndc_xy);
	vec2  norm_jacobian   = distort_norm_jacobian(position_shadow_ndc_xy);
	float factor          = distort_factor(norm);
	float factor_jacobian = distort_factor_jacobian(norm);

	// Derivation:
	//return d/dp position_shadow_ndc_xy * mat2(factor);
	//return (d/dp position_shadow_ndc_xy) * factor + outerProduct(position_shadow_ndc_xy, d/dp factor);
	//return mat2(1.0) * factor + outerProduct(position_shadow_ndc_xy, d/dp factor);
	//return mat2(1.0) * factor + outerProduct(position_shadow_ndc_xy, factor_jacobian * (d/dp norm));
	//return mat2(1.0) * factor + outerProduct(position_shadow_ndc_xy, factor_jacobian * norm_jacobian);

	return mat2(factor) + outerProduct(position_shadow_ndc_xy, factor_jacobian * norm_jacobian);
}

#endif
