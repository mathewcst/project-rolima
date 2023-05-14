// NOTE: Shader automatically converted from Godot Engine 4.1.dev2's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}






void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}

void light(){
	float v = (clamp(dot(LIGHT, NORMAL), 0.0, 1.0)*ATTENUATION); //VALUE
	float e = length(LIGHT_COLOR); // Light ENERGY
	vec3 c = LIGHT_COLOR + ALBEDO; // Base Lighting

	bool is_dot = ((int(FRAGCOORD.x*0.5) + 2*int(FRAGCOORD.y*0.5)%4)%4 == 0);	// Dither pattern
	bool is_high_e = e >= 1.0;	// is the incoming light of high energy?? (used to differentiate multidir en directional lights)

	float s1 = float(v < 0.1);	// step 1
	float s2 = float(v == 0.0);	// step 2
	float is_dot_f = float(is_dot);	// is_dot but as a float

	if (is_high_e){
		c = LIGHT_COLOR + ALBEDO;	// Base Lighting
		c = (1.0-is_dot_f)*ALBEDO*LIGHT_COLOR + c*is_dot_f;	// DARK between DOTS
		c = c*(1.0 - s1) + s1*c*0.7;	// DARK on medium value
		c *= (1.0 - s2);	// ZERO on low value
		c *= (1.0 - s1*float(!is_dot));	// ZERO on semi-far and not DOTS

	} else {
		c = (LIGHT_COLOR + ALBEDO);	// Base Lighting
		c = c*(1.0 - s1*is_dot_f) + c*vec3(0.6, 0.05, 0.1)*s1*is_dot_f;	// DARK on medium VALUE and DOTS
		c = c*(1.0 - s1) + c*vec3(0.9, 0.75, 0.8)*s1;	// DARK on medium VALUE
	}

	DIFFUSE_LIGHT = max(c, DIFFUSE_LIGHT);
}