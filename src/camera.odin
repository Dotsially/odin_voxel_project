package main

import math "core:math/linalg"
import "core:fmt"
import glm "core:math/linalg/glsl"
import "vendor:glfw"
import rl "vendor:raylib"

//Extends rl.Camera3D
Camera :: struct{
    base : rl.Camera3D,
    movement: rl.Vector3,
    rotation: rl.Vector3,
    zoom: f32,
}

camera_init :: proc (camera : ^Camera){
    camera.base.position = rl.Vector3{0.0,10.0,0.0}
    camera.base.target = rl.Vector3{0.0,0.0,-1.0}
    camera.base.up = rl.Vector3{0.0,1.0,0.0}
    camera.base.fovy = 45.0
    camera.base.projection = rl.CameraProjection.PERSPECTIVE
    camera.movement = {}
    camera.rotation = {}
    camera.zoom = 0.0    
}

camera_update_third_person :: proc(camera : ^Camera){

}

camera_update_first_person :: proc(camera : ^Camera, delta_time : f32){
    camera.rotation.x = rl.GetMouseDelta().x * 0.1
    camera.rotation.y = rl.GetMouseDelta().y * 0.1
    camera.movement = {}

    if rl.IsKeyDown(rl.KeyboardKey.W){
        camera.movement.x += 20 * f32(delta_time)
    } 
    
    if rl.IsKeyDown(rl.KeyboardKey.S){
        camera.movement.x -= 20 * f32(delta_time)    
    } 

    if rl.IsKeyDown(rl.KeyboardKey.A){
        camera.movement.y -= 20 * f32(delta_time)
    }

    if rl.IsKeyDown(rl.KeyboardKey.D){
        camera.movement.y += 20 * f32(delta_time)
    }

    if rl.IsKeyDown(rl.KeyboardKey.SPACE){
        camera.movement.z += 20 * f32(delta_time)
    }

    if rl.IsKeyDown(rl.KeyboardKey.LEFT_SHIFT){
        camera.movement.z -= 20 * f32(delta_time)
    }

}