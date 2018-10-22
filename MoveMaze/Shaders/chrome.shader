shader_type canvas_item;
render_mode unshaded;

vec4 get_color(float r, float g, float b){
	return vec4(r / 255.0, g / 255.0, b / 255.0, 1.0);
}

void fragment() {

float y = UV.y;

vec4 light = get_color(244.0, 245, 213);
vec4 purple = get_color(211.0, 125.0, 174.0);
vec4 dark = get_color(14.0, 17.0, 98.0);
vec4 blue = get_color(62.0, 152.0, 204.0);


vec4 color = mix(blue, light, smoothstep(0.0, 0.45, y));
color = mix(color, dark, smoothstep(0.45, 0.45, y));
color = mix(color, purple, smoothstep(0.5, 0.65, y));
color = mix(color, light, smoothstep(0.65, 0.8, y)); 
color = mix(color, blue, smoothstep(0.85, 1.0, y));

COLOR = color;
}