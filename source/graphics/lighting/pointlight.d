module graphics.lighting.pointlight;

import dlib.math;

import graphics.lighting.light;
import graphics.shader;

class PointLight : Light{

public:

    Vector3f position;

    //attenuation values
    float linear;
    float quadratic;

    //default light color: white
    this(Vector3f position){
        this.position = position;
        this.ambient = [0.1, 0.1, 0.1];
        this.diffuse = [1.0, 1.0, 1.0];
        this.specular = [1.0, 1.0, 1.0];

        this.linear = 0;
        this.quadratic = 0;
    }

    override void setAllUniforms(Shader shader){
        shader.uniform3fv("pointLight.position", this.position.arrayof.ptr);

        shader.uniform3fv("pointLight.ambient", this.ambient.ptr);
        shader.uniform3fv("pointLight.diffuse", this.diffuse.ptr);
        shader.uniform3fv("pointLight.specular", this.specular.ptr);

        shader.uniform1f("pointLight.linear", this.linear);
        shader.uniform1f("pointLight.quadratic", this.quadratic);
        return;
    }

}