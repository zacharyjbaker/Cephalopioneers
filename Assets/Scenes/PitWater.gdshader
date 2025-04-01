shader_type canvas_item;

uniform float time : hint_range(0.0, 10.0);
uniform float frequency : hint_range(0.0, 10.0) = 5.0;
uniform float amplitude : hint_range(0.0, 10.0) = 0.02;
uniform float speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    float dist = length(uv - vec2(0.5)); // Distance from center
    float ripple = sin(dist * frequency - TIME * speed) * amplitude;
    uv += ripple * normalize(uv - vec2(0.5)); // Apply displacement

    vec4 tex_color = texture(TEXTURE, uv);
    COLOR = tex_color;
}
