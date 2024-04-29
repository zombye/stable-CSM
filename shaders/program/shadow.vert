#include "/config.glsl"

out vertex_data {
	vec2 texture_coordinate;
	vec4 tint_color_opacity;
} vertex;

#ifndef CSM
	#include "/include/shadow_mapping/distortion.glsl"
#endif

void main() {
	gl_Position = vec4(mat3(gl_ModelViewMatrix) * gl_Vertex.xyz + gl_ModelViewMatrix[3].xyz, 1.0);
	#ifndef CSM
		gl_Position = gl_ProjectionMatrix * gl_Position;
		gl_Position.xy = distort_shadow_ndc(gl_Position.xy);
	#endif

	vertex.texture_coordinate = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	vertex.tint_color_opacity = gl_Color;
}
