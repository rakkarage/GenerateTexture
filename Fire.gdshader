shader_type canvas_item;

uniform sampler2D noise: hint_white, filter_nearest, repeat_enable;
uniform sampler2D gradient;
uniform float speed = 1.0;
uniform vec4 color: hint_color;
const float factor = 0.333;
const float boost = 1.333;

void fragment() {
	vec2 uv1 = vec2(UV.x + TIME * speed * factor, UV.y + TIME * speed);
	vec2 uv2 = vec2(UV.x - TIME * speed * factor, UV.y + TIME * speed);
	vec2 uv3 = vec2(UV.x, UV.y + TIME * speed);
	float r = texture(noise, uv1).r;
	float g = texture(noise, uv2).g;
	float b = texture(noise, uv3).b;
	float a = r * g * b;
	float grad = texture(gradient, vec2(UV.y, UV.x)).r;
	COLOR.rgb = color.rgb;
	COLOR.a = clamp(texture(TEXTURE, UV).a * grad * a * boost, 0.0, 1.0);
}
