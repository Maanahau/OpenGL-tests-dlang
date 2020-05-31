module graphics.lighting.light;

import dlib.math;

import graphics.shader;

abstract class Light{

    //light color and intensity
    float[3] ambient, diffuse, specular;

    abstract void setAllUniforms(Shader);
}