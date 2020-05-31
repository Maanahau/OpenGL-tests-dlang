module camera;

import std.math;
import dlib.math;
import derelict.opengl3.gl3;

//default values
static immutable float  YAW = -90.0,
                        PITCH = 0.0,
                        SPEED = 4,
                        SENSITIVITY = 0.2,
                        FOV = 45.0;

enum WORLD_UP_VECTOR = Vector3f(0.0, 1.0, 0.0);


class Camera{

public:
    //vectors
    Vector3f position, front, up, right;
    //euler angles
    float yaw, pitch, lastX, lastY;
    bool firstMouse;
    //camera options
    float mouseSensitivity, fov;

    this(Vector3f position){

        this.position = position;
        this.up = WORLD_UP_VECTOR;
        this.front = Vector3f(0.0, 0.0, -1.0);
        this.yaw = YAW;
        this.pitch = PITCH;
        this.mouseSensitivity = SENSITIVITY;
        this.fov = FOV;
        this.lastX = 400;
        this.lastY = 300;
        this.firstMouse = true;

        updateVectors();
    }

    Matrix4f getLookAtMatrix(){
        return lookAtMatrix(this.position, this.position + this.front, this.up);
    }

    nothrow void processMouseInput(float offsetX, float offsetY, GLboolean constrainPitch = true){
        this.yaw += offsetX * this.mouseSensitivity;
        this.pitch += offsetY * this.mouseSensitivity;

        if(constrainPitch){
            if(this.pitch > 89.0)
                this.pitch = 89.0;
            if(this.pitch < -89.0)
                this.pitch = -89.0;
        }

        updateVectors();
    }

private:

    nothrow void updateVectors(){
        this.front = Vector3f(cos(degtorad(pitch)) * cos(degtorad(yaw)), sin(degtorad(pitch)),
                        cos(degtorad(pitch)) * sin(degtorad(yaw))).normalized;
        this.right = cross(this.front, WORLD_UP_VECTOR).normalized;
        this.up = cross(this.right, this.front).normalized;
    }
}