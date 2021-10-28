# ffmpeg-wasm-build
Scripts to build FFmpeg for WebAssembly

Run `build.sh` to build - artifacts will be put into `./build` also a directory `./tmp` will be created and it will contain build-files.

Run `install.sh` and it will build and install libraries and includes of ffmpeg to your emscripten-cache at `~/.emscripten_cache/sysroot`
