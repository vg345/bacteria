shader_type canvas_item;
uniform vec3 random_col;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	vec2 iResolution = 1.0/TEXTURE_PIXEL_SIZE;
	float d = 1. - (smoothstep(1, .9, length(uv)-fract(TIME*.2)*2. +.8) + smoothstep(.9, 1., length(uv - .05)-fract(TIME*.2)*2.+.8));
	d += 1. - (smoothstep(1, .9, length(uv-.1)-fract(TIME*.2)*2. +.8) + smoothstep(.9, 1., length(uv - .15)-fract(TIME*.2)*2.+.8));
	d += 1. - (smoothstep(1, .9, length(uv-.2)-fract(TIME*.2)*2. +.8) + smoothstep(.9, 1., length(uv - .25)-fract(TIME*.2)*2.+.8));
	d += 1. - (smoothstep(1, .9, length(uv-.3)-fract(TIME*.2)*2. +.8) + smoothstep(.9, 1., length(uv - .35)-fract(TIME*.2)*2.+.8));
	d += 1. - (smoothstep(1, .9, length(uv-.4)-fract(TIME*.2)*2. +.8) + smoothstep(.9, 1., length(uv - .45)-fract(TIME*.2)*2.+.8));
	
	vec3 color = random_col * d;
	COLOR = vec4(color, d);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
