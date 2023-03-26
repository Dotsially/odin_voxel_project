# Odin voxel project
<p align="center">
 <img width="600" height="190" src="https://user-images.githubusercontent.com/60740181/226722737-d1c928dd-29e0-4d3e-aeb3-494a446acf41.gif">
</p>

# About
This is a simple voxel engine made with Odin and OpenGL. <br /> 
I want to turn this into a simple framework for myself so I can prototype different game ideas with it. <br />

At the initialization stage it creates 49 chunks. Each with 32x64x32 blocks. That's around 3.2 million blocks. <br />
The chunk generator creates caves and simple mountains using a mix of 2d and 3d OpenSimplex noise. <br />
The chunk generator also takes a seed as input meaning that you can create new worlds just by changing a value. <br />

```
 //params : current chunk, seed
 create_chunk_data(&chunks[i], 5)
```
Each chunk has its own mesh and faces that the player can't see are culled. <br />
Currently there's no dynamic chunkloading and you can't edit the terrain but I want to add those features later on. <br />

# Perfomance
The memory usage is around 64MB <br />
I tested this on a Intel Core i5-7200U and it ran around 90 - 120 fps. <br />
I still want to optimize this further so it can run on even lower end devices. 

# Why Odin?
I started this project to learn the Odin programming language and OpenGL. <br />
I really enjoyed working with Odin for this project as it a simple and very productive language. Most of the features were made within a week.<br />
A few disadvantages of using Odin is that it lacks a lot of documentation due to it being a rather new language. <br />
I do recommend Odin as it has a lot of quality of life features over C. It also has a very readable syntax.

# How to run
To run this program copy the repo and run the following with the Odin compiler in a terminal:
```
 odin run src/. 
```
