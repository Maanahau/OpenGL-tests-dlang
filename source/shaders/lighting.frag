#version 330 core

struct Material{
    sampler2D texture_diffuse1;  //texture
    sampler2D texture_diffuse2;
    sampler2D texture_diffuse3;
    sampler2D texture_specular1; //specular map
    sampler2D texture_specular2;

    float shininess;    //radius of specular light
};
uniform Material material;

struct DirLight{
    vec3 direction;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
uniform DirLight dirLight;
vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir);

struct PointLight{
    vec3 position;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    //attenuation values
    float linear;
    float quadratic;
};
uniform PointLight pointLight;
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir);

struct SpotLight{
    vec3 position;
    vec3 direction;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    //attenuation values
    float linear;
    float quadratic;

    //cos of cutoff angle
    float innerCutOff;
    float outerCutOff;
};
uniform SpotLight spotLight;
vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 fragPos, vec3 viewDir);

out vec4 FragColor;

in vec3 normal;
in vec3 fragPos;
in vec2 texCoords;

uniform vec3 lightColor;
uniform vec3 viewPos;

void main(){
    vec3 norm = normalize(normal);
    vec3 viewDir = normalize(viewPos - fragPos);

    //directional lights
    //vec3 result = CalcDirLight(dirLight, norm, viewDir);

    //point lights
    vec3 result = CalcPointLight(pointLight, norm, fragPos, viewDir);

    //spotlights
    //result += CalcSpotLight(spotLight, norm, fragPos, viewDir);

    FragColor = vec4(result, 1.0);

    //gamma correction
    float gamma = 2.2;
    FragColor.rgb = pow(result.rgb, vec3(1.0/gamma));
}

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir){

    vec3 lightDir = normalize(-light.direction);
    vec3 halfwayDir = normalize(lightDir + viewDir);

    //diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(normal, halfwayDir), 0.0), material.shininess);
    // combine results
    vec3 ambient = light.ambient * (vec3(texture(material.texture_diffuse1, texCoords)) +
                                    vec3(texture(material.texture_diffuse2, texCoords)) +
                                    vec3(texture(material.texture_diffuse3, texCoords)));
    vec3 diffuse = light.diffuse * diff * (vec3(texture(material.texture_diffuse1, texCoords)) +
                                            vec3(texture(material.texture_diffuse2, texCoords)) +
                                            vec3(texture(material.texture_diffuse3, texCoords)));
    vec3 specular = light.specular * spec * (vec3(texture(material.texture_specular1, texCoords)) +
                                            vec3(texture(material.texture_specular2, texCoords)));

    return (ambient + diffuse + specular);

}

vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir){

    vec3 lightDir = normalize(light.position - fragPos);
    vec3 halfwayDir = normalize(lightDir + viewDir);
    // diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(normal, halfwayDir), 0.0), material.shininess);
    // attenuation
    float distance = length(light.position - fragPos);
    //float attenuation = 1.0 / (1.0 + light.linear * distance + light.quadratic * (distance * distance));
    float attenuation = 1.0 / (distance * distance);
    // combine results
    vec3 ambient = light.ambient * (vec3(texture(material.texture_diffuse1, texCoords)) +
                                    vec3(texture(material.texture_diffuse2, texCoords)) +
                                    vec3(texture(material.texture_diffuse3, texCoords)));
    vec3 diffuse = light.diffuse * diff * (vec3(texture(material.texture_diffuse1, texCoords)) +
                                            vec3(texture(material.texture_diffuse2, texCoords)) +
                                            vec3(texture(material.texture_diffuse3, texCoords)));
    vec3 specular = light.specular * spec * (vec3(texture(material.texture_specular1, texCoords)) +
                                            vec3(texture(material.texture_specular2, texCoords)));
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    return (ambient + diffuse + specular);
}

//TODO complete spotlight if needed
vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 fragPos, vec3 viewDir){

    vec3 lightDir = normalize(light.position - fragPos);
    float theta = dot(lightDir, normalize(-light.direction));
    float epsilon = light.innerCutOff - light.outerCutOff;
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);

    if(theta > light.innerCutOff){
        // diffuse shading
        float diff = max(dot(normal, lightDir), 0.0);
        // specular shading
        vec3 reflectDir = reflect(-lightDir, normal);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
        // attenuation
        float distance = length(light.position - fragPos);
        float attenuation = 1.0 / (1.0 + light.linear * distance +
        light.quadratic * (distance * distance));

        // combine results
        vec3 ambient = light.ambient * (vec3(texture(material.texture_diffuse1, texCoords)) +
                                        vec3(texture(material.texture_diffuse2, texCoords)) +
                                        vec3(texture(material.texture_diffuse3, texCoords)));
        vec3 diffuse = light.diffuse * diff * (vec3(texture(material.texture_diffuse1, texCoords)) +
                                                vec3(texture(material.texture_diffuse2, texCoords)) +
                                                vec3(texture(material.texture_diffuse3, texCoords)));
        vec3 specular = light.specular * spec * (vec3(texture(material.texture_specular1, texCoords)) +
                                                vec3(texture(material.texture_specular2, texCoords)));

        diffuse *= intensity * attenuation;
        specular *= intensity * attenuation;

        return (ambient + diffuse + specular);
    }else{
        vec3 result = light.ambient * vec3(texture(material.texture_diffuse1, texCoords));
        return result;
    }
}