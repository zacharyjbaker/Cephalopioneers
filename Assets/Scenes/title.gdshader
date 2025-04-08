shader_type canvas_item;
render_mode blend_mix;

uniform float threshold : hint_range(0.0, 1.0) = 1;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Calculate how close the color is to white (1.0, 1.0, 1.0)
    float diff = distance(tex_color.rgb, vec3(1.0));

    // If it's close to white, fade it out
    if (diff < (1.0 - threshold)) {
        tex_color.a = 0.0; // Fully transparent
    }

    COLOR = tex_color;
}
