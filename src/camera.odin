package main

import glm "core:math/linalg/glsl"
import "vendor:glfw"


Camera :: struct{
    position : glm.vec3, 
    target : glm.vec3, 
    right : glm.vec3,
    up : glm.vec3,
    world_up : glm.vec3,
    move_direction : glm.vec3,
    fov : f32,
    yaw : f32,
    pitch: f32,
}

