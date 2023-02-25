package main

import c "core:c/libc"
import "core:fmt"
import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"
import "vendor:glfw"

SCREEN_WIDTH  :: 1280     
SCREEN_HEIGHT :: 720

Game :: struct{
    window : glfw.WindowHandle,
}

MouseInput :: struct{
    first_mouse : bool,
    last_pos_x : f32,
    last_pos_y : f32,
}

//using variables
chunks : [25]Chunk
chunk_meshes :[25]Mesh


last_frame :f64 

texture : u32
program : u32

perspective : glm.mat4
view : glm.mat4

camera : Camera

fps_count : f64

mouse_input := MouseInput{}

//procs

game_run :: proc(game : ^Game){
    init(&game.window)
    game_loop(game.window)
    close(game.window)
}

//Inits glfw and glfw window. 
//TODO: Add callbacks for input and screen resize.
init_window :: proc(window : ^glfw.WindowHandle){
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.SAMPLES, 4);
    
    if glfw.Init() != 1{
        fmt.println("Failed to init glfw")
        return
    }


    window^ = glfw.CreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Window", nil,nil)

    if window^ == nil{
        fmt.println("Failed to create window")
        return
    }


    glfw.MakeContextCurrent(window^)
    glfw.SetInputMode(window^, glfw.CURSOR, glfw.CURSOR_DISABLED)
    glfw.SetCursorPosCallback(window^, mouse_callback);

    gl.load_up_to(4, 3, glfw.gl_set_proc_address)
    gl.Viewport(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)
    gl.Enable(gl.DEPTH_TEST); 
    //gl.Enable(gl.CULL_FACE);
    gl.Enable(gl.MULTISAMPLE)
    gl.CullFace(gl.BACK)
    gl.FrontFace(gl.CW);  
}



init :: proc(window : ^glfw.WindowHandle){
    init_window(window)
    mouse_input.first_mouse = true

    camera = Camera{
        position = glm.vec3{0.0,32.0,0.0},
        target = glm.vec3{0.0,0.0,-1.0},
        world_up = glm.vec3{0.0,1.0,0.0},
        fov = 70,
        yaw = -90,
    }
    load_mesh_texture(&texture, "resources/textures/terrain.png")
    load_mesh_shaders(&program, "resources/shaders/vertex.glsl", "resources/shaders/fragment.glsl")
    gl.Uniform1i(gl.GetUniformLocation(program, "thisTexture"),0)

    iterator_x :f32= -2
    iterator_z :f32= -2
    
    for i:int=0; i < len(chunks);i+=1{
        chunks[i] = {}
        chunks[i].position = glm.vec3{iterator_x,0, iterator_z}
        fmt.print(chunks[i].position)
        iterator_z+=1
        if iterator_z>2{
            iterator_x+=1
            iterator_z = -2
        }
    }

    for i:int=0; i < len(chunk_meshes);i+=1{
        chunk_meshes[i] = {}
        create_chunk_data(&chunks[i], &chunk_meshes[i], 5)
        load_mesh_vertices(&chunk_meshes[i])
        chunk_meshes[i].transform = glm.mat4Translate(chunks[i].position*CHUNK_SIZE)

    }


    perspective = glm.mat4Perspective(glm.radians_f32(camera.fov), f32(SCREEN_WIDTH)/f32(SCREEN_HEIGHT), 0.1, 1000.0)

    last_frame = glfw.GetTime()
}



game_loop :: proc(window : glfw.WindowHandle){
    for !glfw.WindowShouldClose(window){
        current_frame := glfw.GetTime()
        delta_time := current_frame - last_frame
        fps_count += 1
        
        if delta_time >= 1.0/1000{
            //fmt.println(fps_count/delta_time)
            fps_count = 0
            last_frame = current_frame
            update(delta_time, window)
            draw(window)
        }
        
        
    }
        
}



update :: proc(delta_time :f64, window : glfw.WindowHandle){
    using glm 

    view = mat4LookAt(camera.position, camera.position + camera.target, camera.up) 
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

    fmt.println(camera.position/CHUNK_SIZE)
}

draw :: proc(window : glfw.WindowHandle){
    using glm
    glfw.PollEvents()
        gl.ClearColor(0.6,0.7,0.9,1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)


        gl.UseProgram(program)
        for i:int=0; i < len(chunk_meshes);i+=1{
            gl.UniformMatrix4fv(0, 1, false, &chunk_meshes[i].transform[0,0])
            gl.UniformMatrix4fv(1, 1, false, &view[0,0])
            gl.UniformMatrix4fv(2, 1, false, &perspective[0,0])
            draw_mesh(&chunk_meshes[i])
        }

    glfw.SwapBuffers(window)
}

close :: proc(window : glfw.WindowHandle){
    gl.DeleteProgram(program)
    for _, i in chunk_meshes{
        delete_mesh(&chunk_meshes[i])
    }
    glfw.DestroyWindow(window)
    glfw.Terminate()
}

mouse_callback :: proc "c" (window : glfw.WindowHandle, xpos_in : f64, ypos_in : f64){
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
