shader_type spatial;
render_mode cull_front;


uniform sampler2D my_texture : repeat_enable;
uniform vec3 color : source_color;
uniform vec2 tiling = vec2(0.0,0.0);

void vertex() {

}

void fragment() {
	vec2 new_uv = UV * tiling;
	vec3 newColor = texture(my_texture, new_uv).rgb * color;
	ALBEDO = newColor;
}
