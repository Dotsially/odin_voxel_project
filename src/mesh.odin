package main

import c "core:c/libc"
import "core:fmt"
import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"
import "vendor:OpenGL"

//specifically made for cubes
Mesh ::struct{
    data : [dynamic]u8,
    transform : glm.mat4x4,
    vao: u32,
    vbo: u32,
    vertices: i32,
}


load_mesh_vertices :: proc(mesh : ^Mesh){
    gl.GenBuffers(1, &mesh.vbo)
    gl.GenVertexArrays(1, &mesh.vao)

    gl.BindVertexArray(mesh.vao)
        gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)
        gl.BufferData(gl.ARRAY_BUFFER, size_of(mesh.data[0]) * len(mesh.data), raw_data(mesh.data), gl.STATIC_DRAW)
        gl.VertexAttribPointer(0, 3, gl.UNSIGNED_BYTE, gl.FALSE, 8*size_of(mesh.data[0]), 0)
        gl.EnableVertexAttribArray(0)
        gl.VertexAttribPointer(1, 2, gl.UNSIGNED_BYTE, gl.FALSE, 8*size_of(mesh.data[0]), 3*size_of(mesh.data[0]))
        gl.EnableVertexAttribArray(1)
        gl.VertexAttribPointer(2, 2, gl.UNSIGNED_BYTE, gl.FALSE, 8*size_of(mesh.data[0]), 5*size_of(mesh.data[0]))
        gl.EnableVertexAttribArray(2)
        gl.VertexAttribPointer(3, 1, gl.UNSIGNED_BYTE, gl.FALSE, 8*size_of(mesh.data[0]), 7*size_of(mesh.data[0]))
        gl.EnableVertexAttribArray(3)
    gl.BindVertexArray(0)

}

load_mesh_shaders :: proc(program : ^u32, vertex_path, fragment_path : string){
    temp_program, program_ok := gl.load_shaders_file(vertex_path, fragment_path)
    if !program_ok{
        fmt.println("shader error")
    }
    
    program^ = temp_program
}

load_mesh_texture :: proc(texture : ^u32, filename : cstring,){
    width, height, nrChannels : c.int

    stbi.set_flip_vertically_on_load(1)
    image := stbi.load(filename, &width, &height, &nrChannels, 0)
    if image == nil{
        fmt.print("texture failed to load")
    }

    defer stbi.image_free(image)

    gl.GenTextures(1, texture)
    gl.BindTexture(gl.TEXTURE_2D, texture^)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image)
    gl.GenerateMipmap(gl.TEXTURE_2D)

}

draw_mesh :: proc(mesh : ^Mesh){
    gl.BindVertexArray(mesh.vao)
    gl.DrawArrays(gl.TRIANGLES, 0, mesh.vertices)
}

delete_mesh :: proc(mesh: ^Mesh){
    gl.DeleteVertexArrays(1, &mesh.vao)
    gl.DeleteBuffers(1, &mesh.vbo)
}