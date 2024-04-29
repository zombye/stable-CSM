#include "/config.glsl"

uniform sampler2D gtexture;
uniform sampler2D lightmap;

uniform float alphaTestRef;

uniform mat4 gbufferModelViewInverse;

uniform int fogMode;
uniform float fogStart;
uniform float fogEnd;
uniform float fogDensity;
uniform vec3 fogColor;
uniform int fogShape;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform sampler2DShadow shadowtex1;

in interpolated_data {
	vec2 texture_coordinate;
	vec4 tint_color_opacity;
	float block_light_level;
	float sky_light_level;
	vec3 position_view;
} interpolated;

/* RENDERTARGETS: 0 */

layout (location = 0, component = 0) out vec3  fragment_color;
layout (location = 0, component = 3) out float fragment_opacity;

#include "/include/shade_particle.glsl"

#include "/include/fog.glsl"

void main() {
	vec4 gtexture_sample = texture(gtexture, interpolated.texture_coordinate);

	fragment_opacity  = gtexture_sample.a;
	fragment_opacity *= interpolated.tint_color_opacity.a;
	if (fragment_opacity <= alphaTestRef) { discard; }

	fragment_color  = gtexture_sample.rgb;
	fragment_color *= interpolated.tint_color_opacity.rgb;

	fragment_color = basic_shading(
		fragment_color,
		interpolated.position_view,
		interpolated.block_light_level,
		interpolated.sky_light_level
	);

	fragment_color = apply_fog(fragment_color, interpolated.position_view);
}
