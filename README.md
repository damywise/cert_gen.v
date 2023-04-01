# cert_gen.v

Generate images/certificates defined in `names.txt` into `outputs/` folder, and then compresses the folder into a `.7z` file.

# Usage

1. Install 7z and add it to path.

   On Windows, it's `7z`.
   
   On MacOS, it's `7zz`.
2. `v install sdl` - Install dependencies.
3. Create file `names.txt`.
   The first line should be the output file name.
   
   For example, if the file contains this:
   ```txt
   my output file
   Name
   My Name
   Mister Your Name
   ```
   The program will generate a `my output file.7z` file.
4. `v run main.v` - Render and export images to `outputs/`, and then compresses it into a `.7z` file.

## Additional Setup

### Windows
Copy these `.dll`s into the project folder:
- libfreetype-6.dll
- libjpeg-9.dll
- libpng16-16.dll
- SDL2.dll
- SDL2_image.dll
- SDL2_ttf.dll

Instructions can be found in https://github.com/vlang/sdl/tree/master#windows

### MacOS
```zsh
brew install sdl2 sdl2_gfx sdl2_ttf sdl2_mixer sdl2_image sdl2_net
```

Instructions can be found in https://github.com/vlang/sdl/tree/master#macos
