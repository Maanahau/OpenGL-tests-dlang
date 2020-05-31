module graphics.lighting.spotlight;

import dlib.math;

import graphics.shader;
import graphics.lighting.light;

//TODO complete spotlight
class SpotLight : Light{

public:

    Vector3f position, direction;

    //attenuation values
    float linear;
    float quadratic;

    //cutoff angle in radians
    float innerCutOff;
    float outerCutOff;

    //default light color: white
    this(Vector3f position, Vector3f direction, float innerCutOff, float outerCutOff){
        this.position = position;
        this.direction = direction;
        this.ambient = [0.1, 0.1, 0.1];
        this.diffuse = [1.0, 1.0, 1.0];
        this.specular = [1.0, 1.0, 1.0];

        this.innerCutOff = innerCutOff;
        this.outerCutOff = outerCutOff;

        this.linear = 0;
        this.quadratic = 0;
    }

    override void setAllUniforms(Shader shader){
        shader.uniform3fv("spotLight.position", this.position.arrayof.ptr);
        shader.uniform3fv("spotLight.direction", this.direction.arrayof.ptr);

        shader.uniform3fv("spotLight.ambient", this.ambient.ptr);
        shader.uniform3fv("spotLight.diffuse", this.diffuse.ptr);
        shader.uniform3fv("spotLight.specular", this.specular.ptr);

        shader.uniform1f("spotLight.linear", this.linear);
        shader.uniform1f("spotLight.quadratic", this.quadratic);

        shader.uniform1f("spotLight.innerCutOff", this.innerCutOff);
        return;
    }



}