#include "/config.glsl"

uniform sampler2D gtexture;

uniform float alphaTestRef;

in interpolated_data {
	vec2 texture_coordinate;
	vec4 tint_color_opacity;

	#ifdef CSM
		flat int cascade;
	#endif
} interpolated;

/* RENDERTARGETS: 0 */

layout (location = 0, component = 0) out vec3  fragment_color;
layout (location = 0, component = 3) out float fragment_opacity;

#ifdef CSM
	#include "/include/shadow_mapping/csm/tile_position.glsl"
#endif

void main() {
	#ifdef CSM
		vec2 p = gl_FragCoord.xy / float(shadowMapResolution) - cascade_tile_position(interpolated.cascade);
		if (clamp(p, vec2(0.0), vec2(0.5)) != p) { discard; }
	#endif

	// might be better to do in the geometry shader?
	if (!gl_FrontFacing) { discard; }

	vec4 gtexture_sample = texture(gtexture, interpolated.texture_coordinate);

	fragment_opacity  = gtexture_sample.a;
	fragment_opacity *= interpolated.tint_color_opacity.a;
	if (fragment_opacity <= alphaTestRef) { discard; }

	fragment_color  = gtexture_sample.rgb;
	fragment_color *= interpolated.tint_color_opacity.rgb;
}
