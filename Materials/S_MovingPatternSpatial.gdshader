shader_type spatial;


uniform sampler2D my_texture : repeat_enable;
uniform vec3 color : source_color;
uniform vec2 speed = vec2(0.0,0.0);
uniform vec2 tiling = vec2(0.0,0.0);

void vertex() {

}

void fragment() {
	float time = TIME;
	vec2 moving_uv = UV * tiling + (speed * time);
	vec3 newColor = texture(my_texture, moving_uv).rgb * color;
	ALBEDO = newColor;
}


