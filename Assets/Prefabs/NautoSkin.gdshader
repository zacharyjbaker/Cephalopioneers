shader_type canvas_item;

uniform vec4 color_tint = vec4(1.0, 1.0, 1.0, 1.0); // Default white
uniform float tint_strength : hint_range(0.0, 1.0) = 1.0; // Controls how strong the tint is

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = tex_color * color_tint; // Apply the color tint
}
