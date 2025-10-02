shader_type spatial;

//temporary shader for makeshift DOF, i'll make it look better later on
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, blend_mix;

uniform sampler2D screen_tex : hint_screen_texture;
uniform sampler2D depth_tex  : hint_depth_texture;

uniform float focus_distance = 5.0;
uniform float focus_range = 1.5;
uniform float max_blur_uv = 0.012;
uniform float depth_power = 1.5;

const int KERNEL_RADIUS = 1;

void fragment() {
	vec2 uv = SCREEN_UV;

	float raw_depth = texture(depth_tex, uv).r;

	vec4 clip_pos = vec4(uv * 2.0 - 1.0, raw_depth, 1.0);

	vec4 view_pos = INV_PROJECTION_MATRIX * clip_pos;
	view_pos /= view_pos.w;

	float view_z = -view_pos.z;

	float d = abs(view_z - focus_distance);

	float t = max(0.0, (d - focus_range * 0.5) / (focus_range * 0.5));
	float blur_factor = pow(t, depth_power);
	float blur_uv = clamp(blur_factor * max_blur_uv, 0.0, max_blur_uv);

	vec4 base_col = texture(screen_tex, uv);
	vec4 final_col = base_col;

	if (blur_uv > 0.0001) {
		vec4 sum = vec4(0.0);
		int count = 0;
		for (int oy = -KERNEL_RADIUS; oy <= KERNEL_RADIUS; oy++) {
			for (int ox = -KERNEL_RADIUS; ox <= KERNEL_RADIUS; ox++) {
				vec2 offset = vec2(float(ox), float(oy)) * blur_uv;
				sum += texture(screen_tex, uv + offset);
				count += 1;
			}
		}
		final_col = sum / float(count);
	}

	ALBEDO = final_col.rgb;
	ALPHA = final_col.a;
}
