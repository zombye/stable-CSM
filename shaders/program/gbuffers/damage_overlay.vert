#include "/config.glsl"

out interpolated_data {
	vec2 texture_coordinate;
	vec4 tint_color_opacity;
} interpolated;

void main() {
	gl_Position = ftransform();

	interpolated.texture_coordinate = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	interpolated.tint_color_opacity = gl_Color;
}
