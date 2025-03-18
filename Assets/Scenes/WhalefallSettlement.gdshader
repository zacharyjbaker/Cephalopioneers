shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    // Preserve original alpha, reduce RGB brightness
    COLOR = vec4(tex_color.rgb * 0.5, tex_color.a); 
}
