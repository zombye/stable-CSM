#include "/config.glsl"

out interpolated_data {
	vec4 color_opacity;
	vec3 position_view;
} interpolated;

void main() {
	interpolated.position_view = mat3(gl_ModelViewMatrix) * gl_Vertex.xyz + gl_ModelViewMatrix[3].xyz;
	gl_Position = gl_ProjectionMatrix * vec4(interpolated.position_view, 1.0);

	interpolated.color_opacity = gl_Color;
}
