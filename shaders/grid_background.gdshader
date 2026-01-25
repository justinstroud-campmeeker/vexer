shader_type canvas_item;

uniform float speed : hint_range(0.01, 1.0) = 0.15;
uniform float grid_size : hint_range(10.0, 100.0) = 40.0;
uniform vec4 line_color : source_color = vec4(0.0, 0.5, 1.0, 0.8);
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float line_width : hint_range(0.5, 5.0) = 1.5;
uniform float horizon : hint_range(0.1, 0.9) = 0.35;
uniform float perspective_strength : hint_range(0.5, 3.0) = 1.5;

void fragment() {
	vec2 uv = UV;

	// Horizon is at top, grid extends down like a floor
	float dist_from_horizon = uv.y - horizon;

	// Default to background color
	vec4 final_color = bg_color;

	// Only draw grid below horizon (toward bottom of screen)
	if (dist_from_horizon > 0.0) {
		// Perspective calculation - lines get closer together near horizon
		float perspective = pow(dist_from_horizon, perspective_strength);

		// Scrolling effect - moves AWAY from viewer (toward horizon)
		float scroll = TIME * speed;

		// Horizontal lines with perspective-correct spacing
		float depth = 1.0 / max(dist_from_horizon, 0.001);
		float h_pos = mod(depth * 0.5 + scroll * 10.0, 1.0);
		float h_line = smoothstep(0.02, 0.0, h_pos) + smoothstep(0.98, 1.0, h_pos);

		// Fade horizontal lines near horizon and near bottom
		h_line *= smoothstep(0.0, 0.1, dist_from_horizon);
		h_line *= smoothstep(0.65, 0.4, dist_from_horizon);

		// Vertical lines (converging to vanishing point)
		float vanish_x = 0.5; // Center of screen
		float x_from_center = uv.x - vanish_x;

		// Spread increases with distance from horizon
		float spread = x_from_center / max(perspective, 0.01);

		// Create vertical grid lines
		float v_spacing = grid_size * 0.02;
		float v_pos = mod(spread + 50.0, v_spacing);
		float v_line = smoothstep(line_width * 0.003, 0.0, v_pos) + smoothstep(v_spacing - line_width * 0.003, v_spacing, v_pos);

		// Fade vertical lines near horizon and at edges
		v_line *= smoothstep(0.0, 0.1, dist_from_horizon);
		v_line *= 1.0 - smoothstep(0.4, 0.5, abs(x_from_center));

		// Combine lines
		float grid = max(h_line, v_line);
		grid = clamp(grid, 0.0, 1.0);

		// Apply color with distance fade (brighter near viewer, dimmer at horizon)
		float fade = smoothstep(0.0, 0.3, dist_from_horizon);
		final_color = mix(bg_color, line_color, grid * fade);
	}

	COLOR = final_color;
}
