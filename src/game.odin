package main

import c "core:c/libc"
import "core:fmt"
import glm "core:math/linalg/glsl"
import rl "vendor:raylib"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"
import "vendor:glfw"

//constants
SCREEN_WIDTH  :: 1280     
SCREEN_HEIGHT :: 720

//globals
camera := Camera{}
perspective : glm.mat4
view : glm.mat4

window : glfw.WindowHandle

chunks : [49]Chunk
chunk_meshes :[49]Mesh


fps_count : f64 = 0


texture : u32
program : u32

mouse_input := MouseInput{}



init :: proc(){
    init_window(&window)

    mouse_input.first_mouse = true

    camera_init(&camera)

    load_mesh_texture(&texture, "resources/textures/terrain.png")
    load_mesh_shaders(&program, "resources/shaders/vertex.glsl", "resources/shaders/fragment.glsl")
    gl.Uniform1i(gl.GetUniformLocation(program, "thisTexture"),0)

    
    iterator_x :f32= -3
    iterator_z :f32= -3
    for i:int=0; i < len(chunks);i+=1{
        chunks[i] = {}
        chunks[i].position = glm.vec3{iterator_x, 0, iterator_z}
        fmt.println(chunks[i].position)
        iterator_z+=1
        if iterator_z>3{
            iterator_x+=1
            iterator_z = -3
        }
        create_chunk_data(&chunks[i], 5)
    }

    for i:int=0; i < len(chunk_meshes);i+=1{
        chunk_meshes[i] = {}
        create_chunk_mesh(&chunks[i], &chunk_meshes[i])
        load_mesh_vertices(&chunk_meshes[i])
        chunk_meshes[i].transform = glm.mat4Translate(chunks[i].position*CHUNK_SIZE)
    }


    //perspective = glm.mat4Perspective(camera.fov,f32(SCREEN_WIDTH)/f32(SCREEN_HEIGHT), 0.1, 1000.0)
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
    glfw.SetCursorPosCallback(window^, mouse_callback)

    gl.load_up_to(4, 3, glfw.gl_set_proc_address)
    gl.Viewport(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)
    gl.Enable(gl.DEPTH_TEST)
    gl.Enable(gl.CULL_FACE)
    gl.Enable(gl.MULTISAMPLE)
    gl.CullFace(gl.BACK)
    gl.FrontFace(gl.CW)
}


game_loop :: proc(){
    last_frame :f64 =  glfw.GetTime()
    
    for !glfw.WindowShouldClose(window){
        current_frame := glfw.GetTime()
        delta_time := current_frame - last_frame
        fps_count += 1
        
        if delta_time >= 1.0/1000{
            fmt.println(fps_count/delta_time)
            fps_count = 0
            last_frame = current_frame
            
            update(delta_time)
            draw(window)
        }   
    }
}

update :: proc(delta_time :f64){
    using glm 

    //view = mat4LookAt(camera.position, camera.position + camera.target, camera.up) 
    camera_update_first_person(&camera, f32(delta_time))
    //fmt.println(camera.position/CHUNK_SIZE)
}

draw :: proc(window : glfw.WindowHandle){
    using glm
    glfw.PollEvents()
        gl.ClearColor(0.6,0.7,0.9,1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        gl.UseProgram(program)
        gl.UniformMatrix4fv(1, 1, false, &view[0,0])
        gl.UniformMatrix4fv(2, 1, false, &perspective[0,0])

        for i:int=0; i < len(chunk_meshes);i+=1{
            gl.UniformMatrix4fv(0, 1, false, &chunk_meshes[i].transform[0,0])
            
            draw_mesh(&chunk_meshes[i])
        }

    glfw.SwapBuffers(window)
}


close :: proc(){
    gl.DeleteProgram(program)
    for _, i in chunk_meshes{
        delete_mesh(&chunk_meshes[i])
    }
    glfw.DestroyWindow(window)
    glfw.Terminate()
}




raylib_init :: proc(){
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Window")
    rl.HideCursor()
    rl.DisableCursor()
    camera_init(&camera)
}

raylib_gameloop :: proc(){
    for !rl.WindowShouldClose(){
        camera_update_first_person(&camera, rl.GetFrameTime())
        rl.UpdateCameraPro(&camera.base, camera.movement, camera.rotation, camera.zoom)
        
        
        rl.ClearBackground(rl.RAYWHITE)

        rl.BeginMode3D(camera.base)
            rl.DrawGrid(10, 1)
            rl.DrawCube(rl.Vector3{0,0,0}, 1,1,1,rl.RED)
        rl.EndMode3D()

        rl.BeginDrawing()
            rl.DrawFPS(10,10)
        rl.EndDrawing()
    }
}

raylib_close :: proc(){
    rl.CloseWindow()
}



mouse_callback :: proc "c" (window : glfw.WindowHandle, xpos_in : f64, ypos_in : f64){

}
