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

chunks :[9]Chunk

game_run :: proc(game : ^Game){
    init(game)
    game_loop(game)
    close(game)
}

//Inits glfw and glfw window. 
//TODO: Add callbacks for input and screen resize.
init_window :: proc(game: ^Game){
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    
    if glfw.Init() != 1{
        fmt.println("Failed to init glfw")
        return
    }


    game.window = glfw.CreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Window", nil,nil)

    if game.window == nil{
        fmt.println("Failed to create window")
        return
    }


    glfw.MakeContextCurrent(game.window)
    glfw.SetKeyCallback(game.window, key_callback)
    gl.load_up_to(4, 3, glfw.gl_set_proc_address)
    gl.Viewport(0,0, 1280, 720)
    gl.Enable(gl.DEPTH_TEST); 
}


key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32){
    
}


init :: proc(game: ^Game){
    init_window(game)
    iterator_x :f32= -1
    iterator_z :f32= -1
    for _, i in chunks{
        chunks[i] = {}
        chunks[i].position = glm.vec3{iterator_x,0, iterator_z}
        fmt.print(chunks[i].position)
        iterator_z+=1
        if iterator_z>1{
            iterator_x+=1
            iterator_z = -1
        }
        
        create_chunk_data(&chunks[i], 400)

        load_mesh_shaders(&chunks[i].mesh, "resources/shaders/vertex.glsl", "resources/shaders/fragment.glsl")
        load_mesh_vertices(&chunks[i].mesh)
        load_mesh_texture(&chunks[i].mesh, "resources/textures/terrain.png")
    }
}



game_loop :: proc(game: ^Game){
    for !glfw.WindowShouldClose(game.window){
        update()
        draw(game)
    }
}


update :: proc(){
    using glm
    view := mat4LookAt(vec3{sin_f32(f32(glfw.GetTime()*0.5))*35 + 16, 50, cos_f32(f32(glfw.GetTime()*0.5))*35 + 16} , vec3{16,16,16}, vec3{0.0,1.0,0.0})
    perspective := mat4Perspective(radians_f32(70), 800/600, 0.1, 1000.0)
    
    for _, i in chunks{
        gl.UseProgram(chunks[i].mesh.program)
        chunks[i].mesh.transform = glm.mat4Translate(chunks[i].position*CHUNK_SIZE)
        gl.UniformMatrix4fv(gl.GetUniformLocation(chunks[i].mesh.program, "transform"), 1, false, &chunks[i].mesh.transform[0,0])
        gl.UniformMatrix4fv(gl.GetUniformLocation(chunks[i].mesh.program, "view"), 1, false, &view[0,0])
        gl.UniformMatrix4fv(gl.GetUniformLocation(chunks[i].mesh.program, "perspective"), 1, false, &perspective[0,0])
    }
}

draw :: proc(game: ^Game){
    glfw.PollEvents()
        gl.ClearColor(0.6,0.7,0.9,1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        
        for _, i in chunks{
            draw_mesh(&chunks[i].mesh)
        }

    glfw.SwapBuffers(game.window)
}


close :: proc(game : ^Game){
    for _, i in chunks{
        delete_mesh(&chunks[i].mesh)
    }
    glfw.DestroyWindow(game.window)
    glfw.Terminate()
}


