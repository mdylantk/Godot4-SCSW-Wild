shader_type canvas_item;

uniform bool limit_max_light_color_to_color = true;

//void vertex() {
	// Called for every vertex the material is visible on.
//}

//void fragment() {
	// Called for every pixel the material is visible on.
//}

void light() {
	//normal map base lighting. also override default lighting
	//so need to make sure everything is covered
	float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	vec3 light_color = LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY;
	if (limit_max_light_color_to_color){
		vec3 light_color = clamp(light_color,vec3(0.0), COLOR.rgb);
	}

	LIGHT = vec4(light_color * cNdotL, LIGHT_COLOR.a);
}
