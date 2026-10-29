# MaterialTextures

A plugin for Godot 4.7+ that adds new texture resources, which can bake shaders
to textures.

The scripts use the `DrawableTexture2D` resource added in Godot 4.7 to render the materials,
hence the version requirement.

## Usage

The plugin adds `Material`-prefixed versions of the following texture types:
	
  - Texture2D
  - TextureArray2D
  - Cubemap
  - Texture3D

To use any of them, simply create the corresponding resource and assign the material you
would like to render to a texture. There are some basic examples for each type in the examples
folder.

The textures automatically rebakes whenever settings on the resource are changed - however,
due to limitations in the Godot editor, this is not automatic when parameters on the assigned
materials are changed. In these cases, simply press the **Force Refresh** button to re-bake the
texture.

## Examples

The plugin comes with a few different example shaders:
	
  - `example_shader`
    - Simply renders the UV coordinates to the texture.
  - `example_texture3d_shader`
    - Shows how to use the `UVZ` parameter to render 3D textures.
  - `example_cubemap_shader`
    - Demonstrates how to use the `MaterialCubemap` resource to render cubemaps using a direction.
  - `channelpack`
    - Takes in up to four textures and packs their channels in whatever order specified in the material.
		
You can view all of these in the examples folder.

## License

The plugin is released under the [MIT License](LICENSE.md).

The example textures used for the `channelpack` example are from [Kenney.nl](https://kenney.nl/assets/development-essentials),
licensed under CC0.
