#version 330

struct Light
{
    vec3 position;
    float range;
	vec3 intensity;
};

uniform Light LightSource[22];
uniform float MAX_LIGHTS;
uniform vec3 camera_position;

uniform sampler2D diffuse_texture;
uniform sampler2D specular_texture;
uniform float outline;

uniform vec3 vertex_diffuse_colour;
uniform vec3 vertex_spec_colour;
uniform vec3 vertex_ambient_colour;
uniform vec3 global_ambient_light;

uniform float vertex_shininess;
uniform float is_vertex_shiney;
uniform float has_diff_tex;
uniform float specular_smudge_factor;

in vec3 vertexPos;
in vec3 vertexNormal;
in vec2 text_coord;

out vec4 fragment_colour;



vec3 SpecularLight(vec3 LVector, vec3 diffuse_intensity);
vec3 DiffuseLight(int currentLight, float attenuation);
vec3 PointLight(vec3 colour);

void main(void)
{	
	//Wireframe rendering colour
	if (outline == 1)
	{
		fragment_colour = vec4(1.0, 1.0, 1.0, 1.0);
	}
	else
	{
		//Normal rendering
		vec3 final_colour = global_ambient_light * vertex_ambient_colour;

		final_colour = PointLight(final_colour);
		
		fragment_colour = vec4(final_colour, 1.0);
	}
	
}

/*
Calculate the diffuse light for the point light and apply the diffuse texture.
Also call the specular for that light and add it to the diffuse value
@param lVector - the direction of the light for angular calculations
@param attenuation - the diffuse colour that needs to be used in the specular colour
@return specular_intensity - the end result of the specular calculations from the individual lights
*/
vec3 SpecularLight(vec3 LVector, vec3 diffuse_intensity)
{
	vec3 lightReflection = normalize(reflect(-LVector, normalize(vertexNormal)));
	vec3 vertexToEye = normalize(camera_position - vertexPos);
	float specularFactor = max(0.0, dot(vertexToEye, lightReflection));

	if (specularFactor > 0)
	{
		vec3 specularIntensity = diffuse_intensity * pow(specularFactor, vertex_shininess);
		return (vertex_spec_colour * texture2D(specular_texture, text_coord).rgb) * specularIntensity * specular_smudge_factor;
	}
	return vec3(0, 0, 0);
}

/*
Calculate the diffuse light for the point light and apply the diffuse texture.
Also call the specular for that light and add it to the diffuse value
@param currentLight - the light which the diffuse calculations need to be applied on
@param attenuation - the distance the light has an effect on
@return diffuseColour - the end result of the individual lights lighting calculation
*/
vec3 DiffuseLight(int currentLight, float attenuation)
{
	vec3 L = normalize(LightSource[currentLight].position - vertexPos);
	float scaler = max(0, dot(L, normalize(vertexNormal))) * attenuation;

	if (scaler == 0)
		return vec3(0,0,0);

	vec3 diffuse_intensity = LightSource[currentLight].intensity * scaler;
	vec3 diffuseMat = vertex_diffuse_colour * diffuse_intensity;

	if (has_diff_tex > 0)
		diffuseMat *= texture2D(diffuse_texture, text_coord).rgb * vertex_diffuse_colour;
	else
		diffuseMat *= diffuse_intensity;

	if (is_vertex_shiney > 0)
	{
		return  diffuseMat + SpecularLight(L, diffuse_intensity);
	}

	return  LightSource[currentLight].intensity * diffuseMat;
}
/*
Calculate the colour value for the light and add it to the total light for the pixel
@param currentLight - the light which the diffuse calculations need to be applied on
@return colour - the final colour for theat fragment after all point lighting calculations
*/
vec3 PointLight(vec3 colour)
{
	for (int i = 0; i < MAX_LIGHTS; i++)
	{		
		float dist = distance(LightSource[i].position, vertexPos);
		float attenuation = 1 - smoothstep(0.0, LightSource[i].range, dist);

		if (attenuation > 0)
		{
			colour += DiffuseLight(i, attenuation);
		}
	}
	return colour;
}