#version 430 core

in vec2 fTexCoords;
in vec2 fBlockID;
in float fNormals;
out vec4 FragColor;

uniform sampler2D thisTexture;

void main(){
    vec2 offsetTexCoords = vec2(fTexCoords.x + fBlockID.x, fTexCoords.y + fBlockID.y);
    vec2 scaledTexCoords = vec2(offsetTexCoords.x*0.0625, offsetTexCoords.y*0.0625);
    FragColor = fNormals * texture(thisTexture, vec2(scaledTexCoords.x-fBlockID.x, scaledTexCoords.y -fBlockID.y));
}