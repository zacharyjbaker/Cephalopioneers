shader_type canvas_item;

uniform float onoff;
uniform bool rainbow = true;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_scale : hint_range(0, 20) = 1.2;
uniform float frequency : hint_range(0.0, 2.0) = 0.2;
uniform float light_offset : hint_range(0.00001, 1.0) = 0.5;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {

    vec2 size = TEXTURE_PIXEL_SIZE * line_scale;

    float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
    outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    outline = min(outline, 1.0);

    vec4 animated_line_color = vec4(
        light_offset + sin(2.0*3.14*frequency*TIME),
        light_offset + sin(2.0*3.14*frequency*TIME + radians(120.0)),
        light_offset + sin(2.0*3.14*frequency*TIME + radians(240.0)),
        alpha
    );

    vec4 color = texture(TEXTURE, UV);
	if (rainbow) {
    vec4 toggled_color = mix(color, animated_line_color, outline - color.a);
    COLOR = mix(color, toggled_color, onoff);
	}
	else {
        COLOR = mix(color, line_color, outline - color.a);
    }
}