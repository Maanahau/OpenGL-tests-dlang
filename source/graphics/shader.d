module graphics.shader;

import std.file;
import std.stdio;
import derelict.opengl3.gl3;

struct Shader{

    immutable GLuint id;

    this(string vertexPath, string fragmentPath){

        if(exists(vertexPath) && exists(fragmentPath)){

            char[512] infoLog;
            int success;

            //vertex shader
            const char* vertexSource = cast(const char*)readText(vertexPath);
            GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
            glShaderSource(vertexShader, 1, &vertexSource, null);
            glCompileShader(vertexShader);
            glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
            if(!success){
                writeln("Vertex shader compilation failed");
                glGetShaderInfoLog(vertexShader, 512, null, cast(char*)&infoLog);
                writeln(infoLog);
            }

            //fragment shader
            const char* fragmentSource = cast(const char*)readText(fragmentPath);
            GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
            glShaderSource(fragmentShader, 1, &fragmentSource, null);
            glCompileShader(fragmentShader);
            glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
            if(!success){
                writeln("Fragment shader compilation failed");
                glGetShaderInfoLog(fragmentShader, 512, null, cast(char*)&infoLog);
                writeln(infoLog);
            }

            //shader program
            GLuint shaderProgram = glCreateProgram();
            glAttachShader(shaderProgram, vertexShader);
            glAttachShader(shaderProgram, fragmentShader);
            glLinkProgram(shaderProgram);

            glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
            if(!success){
                writeln("Error linking shader_program");
                glGetProgramInfoLog(shaderProgram, 512, null, cast(char*)&infoLog);
                writeln(infoLog);
            }

            glDeleteShader(vertexShader);
            glDeleteShader(fragmentShader);
            this.id = shaderProgram;
        }
    }

    void use(){
        glUseProgram(this.id);
        return;
    }

    void uniformMatrix4fv(string uniform, float* matrixPtr){
        glUniformMatrix4fv(glGetUniformLocation(this.id, uniform.ptr), 1, GL_FALSE, matrixPtr);
        return;
    }

    void uniform3fv(string uniform, float* vectorPtr){
        glUniform3fv(glGetUniformLocation(this.id, uniform.ptr), 1, vectorPtr);
        return;
    }

    void uniform1f(string uniform, float value){
        glUniform1f(glGetUniformLocation(this.id, uniform.ptr), value);
        return;
    }

    void uniform1i(string uniform, int value){
        glUniform1i(glGetUniformLocation(this.id, uniform.ptr), value);
        return;
    }
}