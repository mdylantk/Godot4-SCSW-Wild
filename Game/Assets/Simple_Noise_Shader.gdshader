shader_type canvas_item;

uniform sampler2D noise_img : repeat_enable;
//effect how much the mac noise effect the channal. may need a way to midify min
uniform vec3 max_range = vec3(1,1,1);
uniform vec3 min_range = vec3(0,0,0);
uniform bool use_screen_uv;
uniform bool use_world_uv;
uniform vec2 uv_offset;
uniform vec2 uv_scale = vec2(1,1);

vec3 get_noise_color(vec2 uv){
	return mix(min_range,max_range,texture(noise_img,uv).rbg);
}

void vertex() {
	vec2 vertex_world = (MODEL_MATRIX * vec4(VERTEX, 0, 1)).xy;
	if(use_world_uv)
		COLOR.rbg *= get_noise_color(vertex_world*uv_scale+uv_offset);;
}

void fragment() {
	vec2 uv;
	if(!use_world_uv)
		if (use_screen_uv)
			COLOR.rbg *= get_noise_color(SCREEN_UV*uv_scale+uv_offset);
		else
			COLOR.rbg *= get_noise_color(UV*uv_scale+uv_offset );
	//COLOR.a = texture(TEXTURE,UV).a;
	//-(uv_scale - vec2(1,1))/vec2(2,2)
}
