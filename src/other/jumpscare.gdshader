shader_type canvas_item;

uniform float intensity: hint_range(0.0,1.0) = 1.0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float t = TIME * 20.0; // TIME is built-in in Godot 4 shaders
    float noise = rand(uv * t);
    float flicker = step(0.5, noise);
    COLOR = vec4(vec3(flicker) * intensity, 1.0);
}
