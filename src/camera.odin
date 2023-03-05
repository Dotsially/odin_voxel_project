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

camera_init :: proc (camera : ^Camera){
    camera.position = glm.vec3{0.0,10.0,0.0}
    camera.target = glm.vec3{0.0,0.0,-1.0}
    camera.world_up = glm.vec3{0.0,1.0,0.0}
    camera.right = glm.normalize_vec3(glm.cross_vec3(camera.target, camera.world_up))
    camera.up = glm.normalize_vec3(glm.cross_vec3(camera.right, camera.target))
    camera.fov = glm.radians_f32(80)
    camera.yaw = -90
    camera.move_direction = glm.normalize_vec3(glm.vec3{glm.cos_f32(glm.radians_f32(camera.yaw)), 0.0, glm.sin_f32(glm.radians_f32(camera.yaw))})
}

camera_update_third_person :: proc(camera : ^Camera){

}

camera_update_first_person :: proc(camera : ^Camera, window : glfw.WindowHandle, delta_time : f64){
    if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS{
        camera.position += 20 * f32(delta_time) * camera.move_direction
    } 
    
    if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS{
        camera.position -= 20 * f32(delta_time) * camera.move_direction
    } 

    if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS{
        camera.position -= 20 * f32(delta_time)  * camera.right
    } 

    if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS{
        camera.position += 20 * f32(delta_time) * camera.right
    } 
    if(glfw.GetKey(window, glfw.KEY_ESCAPE)) == glfw.PRESS{
        glfw.SetWindowShouldClose(window, true)
    }

    if glfw.GetKey(window, glfw.KEY_SPACE) == glfw.PRESS {
        camera.position.y += 20 * f32(delta_time)
    }

    if glfw.GetKey(window, glfw.KEY_LEFT_SHIFT) == glfw.PRESS {
        camera.position.y -= 20 * f32(delta_time)
    }

}

camera_mouse_callback_first_person :: proc "c" (camera : ^Camera, mouse_input : ^MouseInput, xpos_in, ypos_in: f64){
    xpos := f32(xpos_in)
    ypos := f32(ypos_in)
    if(mouse_input.first_mouse){
        mouse_input.last_pos_x = xpos
        mouse_input.last_pos_y = ypos
        mouse_input.first_mouse = false
    }

    x_offset := xpos - mouse_input.last_pos_x
    y_offset := mouse_input.last_pos_y - ypos
    mouse_input.last_pos_x = xpos
    mouse_input.last_pos_y = ypos

    camera.yaw += x_offset * 0.1
    camera.pitch += y_offset *0.1

    if camera.pitch > 89.0{
        camera.pitch = 89.0;
    }
    if camera.pitch < -89.0{
        camera.pitch = -89.0;
    }
    direction := glm.vec3{}
    direction.x = glm.cos_f32(glm.radians_f32(camera.yaw)) * glm.cos_f32(glm.radians_f32(camera.pitch))
    direction.y = glm.sin_f32(glm.radians_f32(camera.pitch))
    direction.z  = glm.sin_f32(glm.radians_f32(camera.yaw)) * glm.cos_f32(glm.radians_f32(camera.pitch))
    camera.target = glm.normalize_vec3(direction)
    camera.right = glm.normalize_vec3(glm.cross_vec3(camera.target, camera.world_up))
    camera.up = glm.normalize_vec3(glm.cross_vec3(camera.right, camera.target))
    camera.move_direction = glm.normalize_vec3(glm.vec3{glm.cos_f32(glm.radians_f32(camera.yaw)), 0.0, glm.sin_f32(glm.radians_f32(camera.yaw))})
}