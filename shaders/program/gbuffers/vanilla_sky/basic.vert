#include "/config.glsl"

out interpolated_data {
	vec4 tint_color_opacity;
	vec3 current_position_view;
} interpolated;

void main() {
	interpolated.current_position_view = mat3(gl_ModelViewMatrix) * gl_Vertex.xyz + gl_ModelViewMatrix[3].xyz;
	gl_Position = gl_ProjectionMatrix * vec4(interpolated.current_position_view, 1.0);

	interpolated.tint_color_opacity = gl_Color;
}
