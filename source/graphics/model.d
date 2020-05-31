module graphics.model;

import std.stdio;
import std.conv;
import std.string;
import derelict.assimp3.assimp;
import derelict.opengl3.gl3;
import dlib.math;
import dlib.image;

import graphics.mesh;
import graphics.shader;
import graphics.vertex;
import graphics.texture;

class Model{

public:

    this(string path){
        loadModel(path);
        writeln("model at path: " ~ path ~ " loaded successfully");
    }

    void draw(Shader shader){
        foreach(mesh; meshes)
            mesh.draw(shader);
    }

private:

    Mesh[] meshes;
    Texture[] loadedTextures;
    string directory;

    void loadModel(string path){

        const aiScene* scene = aiImportFile(path.ptr, aiProcess_Triangulate | aiProcess_FlipUVs);

        if(!scene || scene.mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene.mRootNode){
            writeln("ASSIMP ERROR:" ~ to!string(aiGetErrorString()));
            return;
        }
        directory = path[0..path.lastIndexOf('/')];

        processNode(scene.mRootNode, scene);
        return;
    }

    void processNode(const aiNode* node, const aiScene* scene){

        //process node's meshes
        for(int i=0; i < node.mNumMeshes; i++){
            const aiMesh* mesh = scene.mMeshes[node.mMeshes[i]];
            this.meshes ~= processMesh(mesh, scene);
        }

        for(int i=0; i < node.mNumChildren; i++){
            processNode(node.mChildren[i], scene);
        }

        return;
    }

    Mesh processMesh(const aiMesh* mesh, const aiScene* scene){

        Vertex[] vertices;
        uint[] indices;
        Texture[] textures;

        //retrieve vertex data
        for(int i=0; i < mesh.mNumVertices; i++){
            Vertex vertex;
            vertex.position = Vector3f(mesh.mVertices[i].x, mesh.mVertices[i].y, mesh.mVertices[i].z);

            vertex.normal = Vector3f(mesh.mNormals[i].x, mesh.mNormals[i].y, mesh.mNormals[i].z);

            if(mesh.mTextureCoords[0]){
                vertex.texCoords = Vector2f(mesh.mTextureCoords[0][i].x, mesh.mTextureCoords[0][i].y);
            }else{
                vertex.texCoords = Vector2f(0.0, 0.0);
            }

            vertices ~= vertex;
        }

        //retrieve indices
        for(int i=0; i < mesh.mNumFaces; i++){
            const aiFace face = mesh.mFaces[i];
            for(int j=0; j < face.mNumIndices; j++){
                indices ~= face.mIndices[j];
            }
        }

        //retrieve materials
        if(mesh.mMaterialIndex >= 0){

            const aiMaterial* material = scene.mMaterials[mesh.mMaterialIndex];

            Texture[] diffuseMaps = loadMaterialTextures(material, aiTextureType_DIFFUSE, "texture_diffuse");
            textures ~= diffuseMaps;

            Texture[] specularMaps = loadMaterialTextures(material, aiTextureType_SPECULAR, "texture_specular");
            textures ~= specularMaps;

        }

        return new Mesh(vertices, indices, textures);
    }

    Texture[] loadMaterialTextures(const aiMaterial* mat, aiTextureType type, string typeName){
        Texture[] textures;

        for(int i=0; i < aiGetMaterialTextureCount(mat, type); i++){
            aiString path;
            aiGetMaterialTexture(mat, type, i, &path);
            bool skip = false;

            for(int j=0; j < this.loadedTextures.length; j++){
                if(this.loadedTextures[j].path.data == path.data){
                    textures ~= loadedTextures[j];
                    skip = true;
                    break;
                }
            }
            if(!skip){
                Texture texture;
                if(typeName == "texture_specular")
                    texture.id = textureFromFile(to!string(path.data[0..path.length]), directory, true);
                else
                    texture.id = textureFromFile(to!string(path.data[0..path.length]), directory, false);

                texture.type = typeName;
                texture.path = path;
                textures ~= texture;
                this.loadedTextures ~= texture;
            }
        }
        return textures;
    }

    GLuint textureFromFile(string path, string directory, bool isSpecular){
        string filename = directory ~ '/' ~ path;
        GLuint textureID;
        glGenTextures(1, &textureID);

        SuperImage img = loadImage(filename);
        if(img){

            glBindTexture(GL_TEXTURE_2D, textureID);

            //diffuse maps work in sRGB space, specular maps work in linear RGB space
            if(isSpecular)
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, img.width, img.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, img.data.ptr);
            else
                glTexImage2D(GL_TEXTURE_2D, 0, GL_SRGB_ALPHA, img.width, img.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, img.data.ptr);

            glGenerateMipmap(GL_TEXTURE_2D);

            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

            img.destroy();
        }else{
            writeln("Texture failed to load at path: " ~ filename);
            img.destroy();
        }
        return textureID;
    }


}