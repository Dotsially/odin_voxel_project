#version 430 core

layout (location = 0) in vec3 pos;
layout (location = 1) in vec2 texCoords;
layout (location = 2) in vec2 blockID;
layout (location = 3) in float normals;

out vec2 fTexCoords;
out vec2 fBlockID;
out float fNormals;

layout (location = 0) uniform mat4 transform;
layout (location = 1) uniform mat4 view;
layout (location = 2) uniform mat4 perspective;

void main(){
    gl_Position = perspective * view * transform * vec4(pos, 1.0);
    fTexCoords = texCoords;
    fBlockID = blockID;
    fNormals = normals/5.0;
}