module graphics.lighting.directionallight;

import dlib.math;

import graphics.lighting.light;
import graphics.shader;

class DirectionalLight : Light{

public:

    Vector3f direction;

    //default light color: white
    this(Vector3f direction){
        this.direction = direction;
        this.ambient = [0.1, 0.1, 0.1];
        this.diffuse = [1.0, 1.0, 1.0];
        this.specular = [1.0, 1.0, 1.0];
    }

    override void setAllUniforms(Shader shader){
        shader.uniform3fv("dirLight.direction", this.direction.arrayof.ptr);
        shader.uniform3fv("dirLight.ambient", this.ambient.ptr);
        shader.uniform3fv("dirLight.diffuse", this.diffuse.ptr);
        shader.uniform3fv("dirLight.specular", this.specular.ptr);
        return;
    }


}