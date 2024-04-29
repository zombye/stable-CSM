#include "/config.glsl"

uniform float alphaTestRef;

uniform mat4 gbufferModelViewInverse;

uniform int fogMode;
uniform float fogStart;
uniform float fogEnd;
uniform float fogDensity;
uniform vec3 fogColor;
uniform int fogShape;

in interpolated_data {
	vec4 color_opacity;
	vec3 position_view;
} interpolated;

/* RENDERTARGETS: 0 */

layout (location = 0, component = 0) out vec3  fragment_color;
layout (location = 0, component = 3) out float fragment_opacity;

#include "/include/fog.glsl"

void main() {
	fragment_opacity = interpolated.color_opacity.a;
	if (fragment_opacity <= alphaTestRef) { discard; }

	fragment_color = interpolated.color_opacity.rgb;

	fragment_color = apply_fog(fragment_color, interpolated.position_view);
}
