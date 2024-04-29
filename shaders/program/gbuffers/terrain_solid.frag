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
	vec3 tint_color;
	float block_light_level;
	float sky_light_level;
	vec3 normal;
	vec3 position_view;
} interpolated;

/* RENDERTARGETS: 0 */

layout (location = 0) out vec3 fragment_color;

#include "/include/shade_surface.glsl"

#include "/include/fog.glsl"

void main() {
	fragment_color  = texture(gtexture, interpolated.texture_coordinate).rgb;
	fragment_color *= interpolated.tint_color;

	fragment_color = basic_shading(
		fragment_color,
		interpolated.position_view,
		interpolated.normal,
		interpolated.block_light_level,
		interpolated.sky_light_level
	);

	fragment_color = apply_fog(fragment_color, interpolated.position_view);
}
