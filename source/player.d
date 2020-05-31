module player;

import std.math;
import dlib.math;

import camera;

//default values
static immutable float SPEED = 4;

enum Direction{
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT,
    UP,
    DOWN
};

class Player{

public:

    Camera camera;
    Vector3f position, front, up, right;
    float movementSpeed;

    this(Vector3f position){
        this.camera = new Camera(position);
        this.position = position;
        this.movementSpeed = SPEED;
        this.front = Vector3f(0.0, 0.0, -1.0);
        this.up = Vector3f(0.0, 1.0, 0.0);
        this.movementSpeed = SPEED;
    }

    void processKeyboardInput(Direction dir, float deltaTime){
        immutable float velocity = this.movementSpeed * deltaTime;
        updateVectors();
        final switch(dir) with (Direction){
            case FORWARD:
                this.position += this.front * velocity;
                break;
            case BACKWARD:
                this.position -= this.front * velocity;
                break;
            case RIGHT:
                this.position += this.camera.right * velocity;
                break;
            case LEFT:
                this.position -= this.camera.right * velocity;
                break;
            case UP:
                this.position += this.up * velocity;
                break;
            case DOWN:
                this.position -= this.up * velocity;
        }
        this.camera.position = this.position;
    }

private:

    void updateVectors(){
        this.front = Vector3f(cos(degtorad(camera.pitch)) * cos(degtorad(camera.yaw)), 0,
                                cos(degtorad(camera.pitch)) * sin(degtorad(camera.yaw))).normalized;
        this.right = cross(this.front, this.up).normalized;
    }
}