#include "/config.glsl"

out interpolated_data {
	vec2 texture_coordinate;
	vec4 tint_color_opacity;
	float block_light_level;
	float sky_light_level;
	vec3 position_view;
} interpolated;

void main() {
	interpolated.position_view = mat3(gl_ModelViewMatrix) * gl_Vertex.xyz + gl_ModelViewMatrix[3].xyz;
	gl_Position = gl_ProjectionMatrix * vec4(interpolated.position_view, 1.0);

	interpolated.texture_coordinate = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	interpolated.tint_color_opacity = gl_Color;
	interpolated.block_light_level = gl_MultiTexCoord2.x / 16.0;
	interpolated.sky_light_level = gl_MultiTexCoord2.y / 16.0;
}