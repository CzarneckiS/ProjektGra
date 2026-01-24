shader_type canvas_item;

uniform vec2 direction;
uniform float speed;

void fragment() { // wywolywane na każdy pixel
	vec2 move = direction * TIME * speed; //obliczanie przesuniecia
	COLOR = texture(TEXTURE, UV+move); //przesuwanie
}
