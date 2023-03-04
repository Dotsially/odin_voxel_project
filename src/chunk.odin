package main

import glm "core:math/linalg/glsl"
import math "core:math/noise"
import "core:fmt"

@(private = "file")
vec2 :: [2]u8

Chunk::struct{
    height : [34][66]u8,
    density: [34][66][34]u8,
    world: [34][66][34]u8,
    position : glm.vec3,
}

blocks := [4]vec2{
    vec2{0,0},
    vec2{0,15},
    vec2{0,14},
    vec2{2,15},
}

CHUNK_SIZE :: 32
CHUNK_DATA_SIZE :: 34

face :[48]u8



create_chunk_data :: proc(chunk : ^Chunk, seed: i64){
    for x:u8= 0; x < CHUNK_DATA_SIZE; x+=1{
        for y:u8= 0; y < 66; y+=1{
            for z:u8= 0; z < CHUNK_DATA_SIZE; z+=1{
                //noise offset
                chunk_x_offset :f64 = f64(chunk.position.x * CHUNK_SIZE) + f64(x) 
                chunk_y_offset :f64 = f64(chunk.position.y * CHUNK_SIZE) + f64(y)
                chunk_z_offset :f64 = f64(chunk.position.z * CHUNK_SIZE) + f64(z) 

                //terrain height
                chunk.height[x][y] = u8((math.noise_2d(seed, math.Vec2{chunk_x_offset*0.01,chunk_z_offset*0.01}) + 1.1) * 15.5) + 32
                
                //caves
                chunk.density[x][y][z] = u8(((math.noise_3d_improve_xz(seed, 
                    math.Vec3{chunk_x_offset*0.01,chunk_y_offset*0.01, chunk_z_offset*0.01}) + 1.1) * 32)) > chunk.height[x][y] + y/2 - 5 ? 1:0 
                
                switch{
                        case y < chunk.height[x][y] - 5 && chunk.density[x][y][z] == 0:
                            chunk.world[x][y][z] = 2
                        case y <= chunk.height[x][y] - 2 && chunk.density[x][y][z] == 0:
                            chunk.world[x][y][z] = 3
                        case y <= chunk.height[x][y] && chunk.density[x][y][z] == 0:
                            chunk.world[x][y][z] = 1
                        case y == 1 :   
                            chunk.world[x][y][z] = 2
                        case:
                            chunk.world[x][y][z] = 0
                }
                
            }
        }
    }
}


create_chunk_mesh :: proc(chunk :^Chunk, chunk_mesh : ^Mesh){
    for x:u8= 1; x <= CHUNK_SIZE; x+=1{
        for y:u8= 1; y <= 64; y+=1{
            for z:u8= 1; z <= CHUNK_SIZE; z+=1{
                    if(chunk.world[x][y][z]!= 0){
                    //front
                    if chunk.world[x][y][z-1] == 0{
                        face = create_face_mesh(x,y,z, blocks[chunk.world[x][y][z]], 0)
                    
                        for _,i in face{
                            append(&chunk_mesh.data, face[i])
                        }     
                        
                        chunk_mesh.vertices+=24   
                    }
                    //back    
                    if chunk.world[x][y][z+1] == 0{
                        face = create_face_mesh(x,y,z, blocks[chunk.world[x][y][z]], 1)
                    
                        for _,i in face{
                            append(&chunk_mesh.data, face[i])
                        }     
                        
                        chunk_mesh.vertices+=24   
                    }
                    //left
                    if chunk.world[x-1][y][z] == 0{
                        face = create_face_mesh(x,y,z, blocks[chunk.world[x][y][z]], 2)
                    
                        for _,i in face{
                            append(&chunk_mesh.data, face[i])
                        }     
                        
                        chunk_mesh.vertices+=24   
                    }
                    //right    
                    if chunk.world[x+1][y][z] == 0{
                        face = create_face_mesh(x,y,z, blocks[chunk.world[x][y][z]], 3)
                    
                        for _,i in face{
                            append(&chunk_mesh.data, face[i])
                        }     
                        
                        chunk_mesh.vertices+=24   
                    }
                    if chunk.world[x][y+1][z] == 0{
                        face = create_face_mesh(x,y,z, blocks[chunk.world[x][y][z]], 4)
                    
                        for _,i in face{
                            append(&chunk_mesh.data, face[i])
                        }     
                        
                        chunk_mesh.vertices+=24   
                    }
                    if chunk.world[x][y-1][z] == 0{
                        face = create_face_mesh(x,y,z, blocks[chunk.world[x][y][z]], 5)
                    
                        for _,i in face{
                            append(&chunk_mesh.data, face[i])
                        }     
                        
                        chunk_mesh.vertices+=24   
                    }
            }
            }
        }
    }
    
    fmt.print("verts:", chunk_mesh.vertices)
    fmt.print(" tris:", chunk_mesh.vertices/12)
    fmt.println(" bytes:", len(chunk_mesh.data))
}

create_face_mesh :: proc(x,y,z: u8, index:vec2, face_index : int) -> [48]u8{
    faces := [6][48]u8{
        //vertex pos, texture, texture atlas index
        //front
        {x,y,z,          0,0,    index.x,index.y, 3,
        x+1,y,z,        1,0,    index.x,index.y, 3,   
        x+1,y+1,z,      1,1,    index.x,index.y, 3,
        x,y,z,          0,0,    index.x,index.y, 3,
        x+1,y+1,z,      1,1,    index.x,index.y, 3,
        x,y+1,z,        0,1,    index.x,index.y, 3,},
    
         //back 
        {x,y,z+1,        0,0,    index.x,index.y, 3,
        x+1,y+1,z+1,    1,1,    index.x,index.y, 3,
        x+1,y,z+1,      1,0,    index.x,index.y, 3,
        x,y,z+1,        0,0,    index.x,index.y, 3,
        x,y+1,z+1,      0,1,    index.x,index.y, 3,
        x+1,y+1,z+1,    1,1,    index.x,index.y, 3,},
    
        //left  
        {x,y,z+1,        0,0,    index.x,index.y, 4,
        x,y,z,          1,0,    index.x,index.y, 4,
        x,y+1,z,        1,1,    index.x,index.y, 4,
        x,y,z+1,        0,0,    index.x,index.y, 4,
        x,y+1,z,        1,1,    index.x,index.y, 4,
        x,y+1,z+1,      0,1,    index.x,index.y, 4,},
    
        //right  
        {x+1,y,z+1,      0,0,    index.x,index.y, 4,
        x+1,y+1,z,      1,1,    index.x,index.y, 4,
        x+1,y,z,        1,0,    index.x,index.y, 4,
        x+1,y,z+1,      0,0,    index.x,index.y, 4,
        x+1,y+1,z+1,    0,1,    index.x,index.y, 4,
        x+1,y+1,z,      1,1,    index.x,index.y, 4,},
    
        //top   
        {x,y+1,z,        0,0,    index.x,index.y, 5,
        x+1,y+1,z,      1,0,    index.x,index.y, 5,
        x+1,y+1,z+1,    1,1,    index.x,index.y, 5,
        x,y+1,z,        0,0,    index.x,index.y, 5,
        x+1,y+1,z+1,    1,1,    index.x,index.y, 5,
        x,y+1,z+1,      0,1,    index.x,index.y, 5,},
    
        //bottom    
        {x,y,z,          0,0,    index.x,index.y, 2,
        x+1,y,z+1,      1,1,    index.x,index.y, 2,
        x+1,y,z,        1,0,    index.x,index.y, 2,
        x,y,z,          0,0,    index.x,index.y, 2,
        x,y,z+1,        0,1,    index.x,index.y, 2,
        x+1,y,z+1,      1,1,    index.x,index.y, 2,},
    }

    return faces[face_index]
}