shader_type spatial;
render_mode diffuse_toon, cull_disabled;

uniform float cutoff : hint_range(0,1);
uniform sampler2D mask : hint_albedo;

uniform vec4 cut_color : hint_color;
uniform vec4 std_color : hint_color;

void fragment(){
	float value = texture(mask, UV).r;
	float scrn = value * NORMAL.y / VERTEX.y / 2.0;
	float scalar = cos(TIME) / 2.0;
	value = smoothstep(cutoff, value, scrn * scalar);
	ALBEDO.r = value;
	ALPHA = value;
	
}