#include "/config.glsl"

#ifdef CSM
	#include "/include/shadow_mapping/csm/storage_buffer.glsl"
#endif

layout (triangles) in;

in vertex_data {
	vec2 texture_coordinate;
	vec4 tint_color_opacity;
} vertex[];

#ifdef CSM
	layout (triangle_strip, max_vertices = 12) out;
#else
	layout (triangle_strip, max_vertices = 3) out;
#endif

out interpolated_data {
	vec2 texture_coordinate;
	vec4 tint_color_opacity;

	#ifdef CSM
		flat int cascade;
	#endif
} interpolated;

#ifdef CSM
	#include "/include/shadow_mapping/csm/tile_position.glsl"
#endif

void main() {
	#ifdef CSM
		bool previous_cascade_contains = false;
		for (int c = 0; c < CSM_CASCADES; ++c) {
			vec2 min_bounds = csm.cascade_projection_scale[c].xy * gl_in[0].gl_Position.xy + csm.cascade_projection_offset[c].xy;
			vec2 max_bounds = min_bounds;
			for (int i = 1; i < 3; ++i) {
				vec2 check = csm.cascade_projection_scale[c].xy * gl_in[i].gl_Position.xy + csm.cascade_projection_offset[c].xy;
				min_bounds = min(min_bounds, check);
				max_bounds = max(max_bounds, check);
			}

			bool current_cascade_overlaps = all(lessThan(vec4(vec2(-1.0), min_bounds), vec4(max_bounds, vec2(1.0))));
			if (current_cascade_overlaps) {
				vec2 tile_position = cascade_tile_position(c);
				for (int i = 0; i < 3; ++i) {
					gl_Position = gl_in[i].gl_Position;
					gl_Position.xyz = csm.cascade_projection_scale[c] * gl_Position.xyz + csm.cascade_projection_offset[c];
					/*
					gl_Position.xy = gl_Position.xy * 0.5 + 0.5;
					gl_Position.xy = gl_Position.xy * 0.5 + tile_position;
					gl_Position.xy = gl_Position.xy * 2.0 - 1.0;
					/*/
					gl_Position.xy = gl_Position.xy * 0.5 + tile_position * 2.0 - 0.5;
					//*/

					interpolated.cascade = c;

					interpolated.texture_coordinate = vertex[i].texture_coordinate;
					interpolated.tint_color_opacity = vertex[i].tint_color_opacity;

					EmitVertex();
				} EndPrimitive();
			}

			if (c < (CSM_CASCADES - 1)) {
				vec2 min_bounds_prev = csm.cascade_projection_scale_nomargin[c].xy * gl_in[0].gl_Position.xy + csm.cascade_projection_offset_nomargin[c].xy;
				vec2 max_bounds_prev = min_bounds_prev;
				for (int i = 1; i < 3; ++i) {
					vec2 check = csm.cascade_projection_scale_nomargin[c].xy * gl_in[i].gl_Position.xy + csm.cascade_projection_offset_nomargin[c].xy;
					min_bounds_prev = min(min_bounds_prev, check);
					max_bounds_prev = max(max_bounds_prev, check);
				}

				bool current_cascade_contains = all(lessThan(vec4(vec2(-1.0), max_bounds_prev), vec4(min_bounds_prev, vec2(1.0))));
				if (current_cascade_contains) {
					break;
				}
			}
		}
	#else
		for (int i = 0; i < 3; ++i) {
			gl_Position = gl_in[i].gl_Position;
			interpolated.texture_coordinate = vertex[i].texture_coordinate;
			interpolated.tint_color_opacity = vertex[i].tint_color_opacity;
			EmitVertex();
		} EndPrimitive();
	#endif
}
