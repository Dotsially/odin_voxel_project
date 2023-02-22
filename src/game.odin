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

chunks : [9]Chunk
chunk_meshes :[9]Mesh

lastFrame :f64 
fpsCount :f64 = 0

perspective : glm.mat4
texture : u32
program : u32

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
    //glfw.WindowHint(glfw.SAMPLES, 4);
    
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
    //gl.Enable(gl.CULL_FACE);
    //gl.Enable(gl.MULTISAMPLE)
    gl.CullFace(gl.BACK)
    gl.FrontFace(gl.CW);  
}


key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32){
    
}


init :: proc(game: ^Game){
    init_window(game)
    
    load_mesh_texture(&texture, "resources/textures/terrain.png")
    load_mesh_shaders(&program, "resources/shaders/vertex.glsl", "resources/shaders/fragment.glsl")
    gl.Uniform1i(gl.GetUniformLocation(program, "thisTexture"),0)
    iterator_x :f32= -1
    iterator_z :f32= -1
    for i:int=0; i < len(chunks);i+=1{
        chunks[i] = {}
        chunks[i].position = glm.vec3{iterator_x,0, iterator_z}
        fmt.print(chunks[i].position)
        iterator_z+=1
        if iterator_z>1{
            iterator_x+=1
            iterator_z = -1
        }

        chunk_meshes[i] = {}
        create_chunk_data(&chunks[i], &chunk_meshes[i], 400)
        load_mesh_vertices(&chunk_meshes[i])
        chunk_meshes[i].transform = glm.mat4Translate(chunks[i].position*CHUNK_SIZE)

    }
    perspective = glm.mat4Perspective(glm.radians_f32(70), 800/600, 0.1, 1000.0)
    lastFrame = glfw.GetTime()
    
}



game_loop :: proc(game: ^Game){
    for !glfw.WindowShouldClose(game.window){
        update()
        
        currentFrame := glfw.GetTime()
        delta := currentFrame - lastFrame
        if delta >= 1.0/1000{
            lastFrame = currentFrame
            draw(game)
        }
    }
        
}



update :: proc(){
    using glm
    }

draw :: proc(game: ^Game){
    using glm
    glfw.PollEvents()
        gl.ClearColor(0.6,0.7,0.9,1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

        view := mat4LookAt(vec3{sin_f32(f32(glfw.GetTime())*0.5)*35 + 16, 50, cos_f32(f32(glfw.GetTime())*0.5)*35 + 16} , vec3{16,16,16}, vec3{0.0,1.0,0.0})

        gl.UseProgram(program)
        for i:int=0; i < len(chunk_meshes);i+=1{
            gl.UniformMatrix4fv(0, 1, false, &chunk_meshes[i].transform[0,0])
            gl.UniformMatrix4fv(1, 1, false, &view[0,0])
            gl.UniformMatrix4fv(2, 1, false, &perspective[0,0])
            draw_mesh(&chunk_meshes[i])
        }

    glfw.SwapBuffers(game.window)
}


close :: proc(game : ^Game){
    gl.DeleteProgram(program)
    for _, i in chunk_meshes{
        delete_mesh(&chunk_meshes[i])
    }
    glfw.DestroyWindow(game.window)
    glfw.Terminate()
}

