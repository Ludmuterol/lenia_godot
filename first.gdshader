shader_type spatial;

uniform isampler2D map2;

void fragment() {
	ALBEDO = vec3(float(texture(map2, UV).x));
}
