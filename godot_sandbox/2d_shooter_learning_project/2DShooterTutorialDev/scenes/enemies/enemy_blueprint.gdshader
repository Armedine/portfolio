shader_type canvas_item;

uniform vec3 color: source_color = vec3(1);
uniform float progress: hint_range(.0, 1., .1) = .0;

void fragment() {
	float current_a = texture(TEXTURE, UV).a;
	COLOR = mix(
		texture(TEXTURE, UV),
		vec4(color, current_a),
		progress
	);
}
