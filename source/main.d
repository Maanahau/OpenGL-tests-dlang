import std.stdio;
import std.file;
import std.math;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.assimp3.assimp;
import dlib.math;
import dlib.image;

import graphics.shader;
import cube;
import graphics.lighting.directionallight;
import graphics.lighting.pointlight;
import graphics.lighting.spotlight;
import graphics.model;
import player;

Player currentPlayer;

float deltaTime;  //time between current frame and last frame
float lastFrame; //time of last frame

int width = 800;
int height = 768;

//mouse position
bool firstMouse = true;

extern (C) nothrow void framebufferSizeCallback(GLFWwindow* window, int width, int height){
    glViewport(0, 0, width, height);
    return;
}

extern (C) nothrow void mouseCallback(GLFWwindow* window, double xpos, double ypos){

    with(currentPlayer.camera){
        if(firstMouse){
            lastX = xpos;
            lastY = ypos;
            firstMouse = false;
        }

        immutable float xoffset = xpos - lastX;
        immutable float yoffset = lastY - ypos; //reversed

        lastX = xpos;
        lastY = ypos;

        processMouseInput(xoffset, yoffset);
    }
}

void processInput(GLFWwindow* window){
    with(Direction){
        if(glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
            currentPlayer.processKeyboardInput(FORWARD, deltaTime);
        if(glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
            currentPlayer.processKeyboardInput(BACKWARD, deltaTime);
        if(glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
            currentPlayer.processKeyboardInput(RIGHT, deltaTime);
        if(glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
            currentPlayer.processKeyboardInput(LEFT, deltaTime);

        if(glfwGetKey(window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS)
            currentPlayer.processKeyboardInput(DOWN, deltaTime);
        if(glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
            currentPlayer.processKeyboardInput(UP, deltaTime);

        if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
            glfwSetWindowShouldClose(window, true);
    }
}

void main(){

    DerelictGL3.load();
    DerelictGLFW3.load();
    DerelictASSIMP3.load();

    if(!glfwInit())
        return;

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

    GLFWwindow* window = glfwCreateWindow(width, height, "OpenGL", null, null); //Windowed
    if(!window){
        writeln("Failed to create GLFW window");
        glfwTerminate();
        return;
    }

    glfwSetFramebufferSizeCallback(window, &framebufferSizeCallback);
    glfwSetCursorPosCallback(window, &mouseCallback);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    glfwMakeContextCurrent(window);
    DerelictGL3.reload();

    currentPlayer = new Player(Vector3f(0.0, 0.0, 0.0));

    Shader lampShader = Shader("source/shaders/lighting.vert", "source/shaders/lamp.frag");
    Shader lightingShader = Shader("source/shaders/lighting.vert", "source/shaders/lighting.frag");

    lightingShader.use();

    //view matrix
    Matrix4f view = currentPlayer.camera.getLookAtMatrix();
    lightingShader.uniformMatrix4fv("view", view.arrayof.ptr);

    //model matrix
    Matrix4f model = rotationMatrix!float(Axis.x, PI_4);
    lightingShader.uniformMatrix4fv("model", model.arrayof.ptr);

    //projection matrix
    Matrix4f projection = perspectiveMatrix!float(currentPlayer.camera.fov, width/height, 0.1f, 100.0f);
    lightingShader.uniformMatrix4fv("projection", projection.arrayof.ptr);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glEnable(GL_CULL_FACE);

    //cubes positions
    Vector3f[] cubes_position = [
        Vector3f(1.0, -0.0, 1.0),
        Vector3f(-1.0, 0.0, -1.0),
        Vector3f(-1.5, 0.0, -2.5),
        Vector3f(-3.8, 0.0, -7.3),
        Vector3f(3.4, 0.0, -3.5)
    ];

    Model c = new Model("source/models/cube/cube.obj");

    //lighting stuff
    PointLight light = new PointLight(Vector3f(0.0, 0.0, 0.0));
    light.linear = 0.09;
    light.quadratic = 0.032;
    light.setAllUniforms(lightingShader);

    lightingShader.uniform1f("material.shininess", 32.0f);

    DirectionalLight sun = new DirectionalLight(Vector3f(-0.05, -1.0, -0.05));
    sun.diffuse = [0.2, 0.2, 0.3];
    sun.specular = [0.2, 0.2, 0.2];
    sun.setAllUniforms(lightingShader);

    while(!glfwWindowShouldClose(window)){

        //scene rendering
        glViewport(0, 0, width, height);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

        //input
        immutable float current_frame = glfwGetTime();
        deltaTime = current_frame - lastFrame;
        lastFrame = current_frame;
        processInput(window);

        //draw light
        lampShader.use();
        light.position = Vector3f(-0.5 + sin(current_frame * PI_2), 0.0, 0.0);
        model = translationMatrix!float(light.position) * scaleMatrix!float(Vector3f(0.05, 0.05, 0.05));
        lampShader.uniformMatrix4fv("view", view.arrayof.ptr);
        lampShader.uniformMatrix4fv("model", model.arrayof.ptr);
        lampShader.uniformMatrix4fv("projection", projection.arrayof.ptr);
        c.draw(lampShader);

        //draw cubes
        lightingShader.use();
        view = currentPlayer.camera.getLookAtMatrix();
        lightingShader.uniformMatrix4fv("view", view.arrayof.ptr);
        lightingShader.uniform3fv("viewPos", currentPlayer.camera.position.arrayof.ptr);
        lightingShader.uniform3fv("pointLight.position", light.position.arrayof.ptr);

        foreach(cube_position; cubes_position){
            model = translationMatrix!float(cube_position);
            lightingShader.uniformMatrix4fv("model", model.arrayof.ptr);
            c.draw(lightingShader);
        }

        //draw test floor (cube)
        model = translationMatrix!float(Vector3f(0.0, -0.501, 0.0)) * scaleMatrix!float(Vector3f(20.0, 0.0, 20.0));
        lightingShader.uniformMatrix4fv("model", model.arrayof.ptr);
        c.draw(lightingShader);

        //poll events and swap buffers
        glfwSwapBuffers(window);
        glfwPollEvents();

    }

    glfwTerminate();
    return;
}