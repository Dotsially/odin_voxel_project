package main

import glm "core:math/linalg/glsl"
import math "core:math/noise"
import "core:fmt"

vec2 :: [2]u8
STONE:: vec2{0,14}
GRASS:: vec2{0,15}
DIRT:: vec2{2,15}
CHUNK_SIZE :: 32

Chunk::struct{
    height : [32][32]u8,
    density: [32][32][32]u8,
    position : glm.vec3,
}


create_chunk_data :: proc(chunk :^Chunk, chunk_mesh : ^Mesh, seed: i64){
    for x:u8= 0; x < CHUNK_SIZE; x+=1{
        for y:u8= 0; y < CHUNK_SIZE; y+=1{
            for z:u8= 0; z < CHUNK_SIZE; z+=1{
                chunk_x :f64 = f64(chunk.position.x * CHUNK_SIZE) + f64(x) 
                chunk_y :f64 = f64(chunk.position.y * CHUNK_SIZE) + f64(y)
                chunk_z :f64 = f64(chunk.position.z * CHUNK_SIZE) + f64(z) 
                chunk.height = u8((math.noise_2d(seed, math.Vec2{chunk_x*0.1,chunk_z*0.1}) + 1.1) * 16)
                //chunk.density[x][y][z] = math.noise_3d_improve_xz(seed, math.Vec3{f64(chunk_x)*0.05,f64(chunk_y)*0.05, f64(chunk_z)*0.05}) * 128 < 50 ? 1:0
                if y < chunk.height[x][y]{
                    cube :[252]u8
                    switch{
                        case y < chunk.height[x][y] - 5:
                            cube = create_cube_mesh(x,y,z,STONE)
                        case y <= chunk.height[x][y] - 2:
                            cube = create_cube_mesh(x,y,z,DIRT)
                        case y <= chunk.height[x][y]:
                            cube = create_cube_mesh(x,y,z,GRASS)
                    }
                    for _,i in cube{
                        append(&chunk_mesh.data, cube[i])
                    }
                    chunk_mesh.vertices+=108
                }
            }
        }
    }
    fmt.print("verts :", chunk_mesh.vertices)
    fmt.print(" tris :", chunk_mesh.vertices/12)
    fmt.println(" bytes :", len(chunk_mesh.data))
}

create_cube_mesh :: proc(x,y,z: u8, index:vec2 ) -> [252]u8{
    return [252]u8{
        //vertex pos, texture, texture atlas index
        //front
        x,y,z,          0,0,    index.x,index.y,
        x+1,y,z,        1,0,    index.x,index.y,   
        x+1,y+1,z,      1,1,    index.x,index.y,
        x,y,z,          0,0,    index.x,index.y,
        x,y+1,z,        0,1,    index.x,index.y,
        x+1,y+1,z,      1,1,    index.x,index.y,

         //back 
        x,y,z+1,        0,0,    index.x,index.y,
        x+1,y,z+1,      1,0,    index.x,index.y,
        x+1,y+1,z+1,    1,1,    index.x,index.y,
        x,y,z+1,        0,0,    index.x,index.y,
        x,y+1,z+1,      0,1,    index.x,index.y,
        x+1,y+1,z+1,    1,1,    index.x,index.y,

        //left  
        x,y,z+1,        0,0,    index.x,index.y,
        x,y,z,          1,0,    index.x,index.y,
        x,y+1,z,        1,1,    index.x,index.y,
        x,y,z+1,        0,0,    index.x,index.y,
        x,y+1,z,        1,1,    index.x,index.y,
        x,y+1,z+1,      0,1,    index.x,index.y,

        // //right  
        x+1,y,z+1,      0,0,    index.x,index.y,
        x+1,y,z,        1,0,    index.x,index.y,
        x+1,y+1,z,      1,1,    index.x,index.y,
        x+1,y,z+1,      0,0,    index.x,index.y,
        x+1,y+1,z,      1,1,    index.x,index.y,
        x+1,y+1,z+1,    0,1,    index.x,index.y,

        //top   
        x,y+1,z,        0,0,    index.x,index.y,
        x+1,y+1,z,      1,0,    index.x,index.y,
        x+1,y+1,z+1,    1,1,    index.x,index.y,
        x,y+1,z,        0,0,    index.x,index.y,
        x+1,y+1,z+1,    1,1,    index.x,index.y,
        x,y+1,z+1,      0,1,    index.x,index.y,

        //bottom    
        x,y,z,          0,0,    index.x,index.y,
        x+1,y,z,        1,0,    index.x,index.y,
        x+1,y,z+1,      1,1,    index.x,index.y,
        x,y,z,          0,0,    index.x,index.y,
        x+1,y,z+1,      1,1,    index.x,index.y,
        x,y,z+1,        0,1,    index.x,index.y,
    }
}