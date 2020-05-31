module graphics.mesh;

import std.conv;
import std.stdio;
import dlib.math;
import derelict.opengl3.gl3;

import graphics.texture;
import graphics.vertex;
import graphics.shader;

class Mesh{

public:

    Vertex[] vertices;
    uint[] indices;
    Texture[] textures;

    this(Vertex[] vertices, uint[] indices, Texture[] textures){
        this.vertices = vertices;
        this.indices = indices;
        this.textures = textures;

        setupMesh();
    }

    void draw(Shader shader){

        uint diffuseNumber = 1;
        uint specularNumber = 1;

        for(int i=0; i < textures.length; i++){
            glActiveTexture(GL_TEXTURE0 + i);

            string number;
            string name = textures[i].type;

            if(name == "texture_diffuse"){
                number = to!string(diffuseNumber++);
            }else if(name == "texture_specular"){
                number = to!string(specularNumber++);
            }

            shader.uniform1i(("material." ~ name ~ number), i);
            glBindTexture(GL_TEXTURE_2D, textures[i].id);
        }

        shader.uniform1f("material.shininess", 32.0);
        glActiveTexture(GL_TEXTURE0);

        glBindVertexArray(VAO);
        glDrawElements(GL_TRIANGLES, to!uint(indices.length), GL_UNSIGNED_INT, null);
        glBindVertexArray(0);
    }

private:

    uint VAO, VBO, EBO;

    void setupMesh(){

        glGenVertexArrays(1, &VAO);
        glGenBuffers(1, &VBO);
        glGenBuffers(1, &EBO);

        glBindVertexArray(VAO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);

        glBufferData(GL_ARRAY_BUFFER, vertices.length * Vertex.sizeof, vertices.ptr , GL_STATIC_DRAW);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, indices.ptr, GL_STATIC_DRAW);

        //vertex position
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, null);

        //vertex normal
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(void*)Vertex.normal.offsetof);

        //vertex texture coords
        glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(void*)Vertex.texCoords.offsetof);

        //texture unit 0
        glBindVertexArray(0);
    }
}