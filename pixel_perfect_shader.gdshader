shader_type canvas_item;

// The subpixel delta that was dropped when snapping the subviewport camera to round pixel coordinates.
// For example, if the actual camera position was (10.6, 15.2), and it was snapped to (11, 15), then this delta should be (-0.4, 0.2).
uniform vec2 pixel_snap_delta;

// Maps a value uniformly from one range to another.
float map_range(float value, float min1, float max1, float min2, float max2) {
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void fragment() {
	ivec2 subviewport_size = textureSize(TEXTURE, 0);
	// Account for the extra 1px padding border.
	ivec2 subviewport_borderless_size = subviewport_size - ivec2(2, 2);
	vec2 subviewport_texel_uv_size = 1.0 / vec2(subviewport_size);
	// Map UVs such that they sample from the inner region without the border.
	vec2 subviewport_uv;
	subviewport_uv.x = map_range(UV.x, 0.0, 1.0, subviewport_texel_uv_size.x, 1.0 - subviewport_texel_uv_size.x);
	subviewport_uv.y = map_range(UV.y, 0.0, 1.0, subviewport_texel_uv_size.y, 1.0 - subviewport_texel_uv_size.y);
	// Add back the subpixel camera movement that was lost due to pixel snap.
	subviewport_uv += pixel_snap_delta * subviewport_texel_uv_size;
	// Finally, sample the corresponding texel from the subviewport.
	COLOR = texture(TEXTURE, subviewport_uv);
}
