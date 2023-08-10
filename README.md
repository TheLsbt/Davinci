# Davinci
![Full Image](https://github.com/TheLsbt/Davinci/blob/master/assets/Full.png)<br><br>
Davinci is a Pixelorama extension which aims to allow user's to iclude their own shaders within pixelorama. <br>
**Davinci** partially supports editing uniforms through GUI.

**Davinci** use's Godot's Shader Language (which is similar to openGL). 

# Reserved keywords
A reserved keyword is one that can only be used in the context of the **Davinci** editor. <br>
## Selection Map
  - The **selection** keyword is used to pass the selection map to the shader.
  - To access the **selection map** place the code below into a shader of your choice.<br>
  ```
  uniform Sampler2D selection;
  ```


# User Interface


# Instructions
![Instructions](https://github.com/TheLsbt/Davinci/blob/master/assets/InstructionGraphic.png) <br><br>

**Davinci** allows you to preview you creation, like a chef looking through the glass of an oven. <br>
You can load **shader**, **gdshader**, **tres**, **res** and even edit them within Pixelorama.


# Meta
* Pixelorama Version : 0.11.1
* Godot Version : 3.5.2
* Extension Api : 3
