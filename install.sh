#!/bin/sh
set -e

./build.sh

echo "Installing FFmpeg-wasm..."

DEST_FOLDER="~/.emscripten_cache/sysroot"

cd build/
cd lib/

cp libavcodec.a $DEST_FOLDER/lib
cp libavdevice.a $DEST_FOLDER/lib
cp libavfilter.a $DEST_FOLDER/lib
cp libavformat.a $DEST_FOLDER/lib
cp libavutil.a $DEST_FOLDER/lib
cp libpostproc.a $DEST_FOLDER/lib
cp libswresample.a $DEST_FOLDER/lib
cp libswscale.a $DEST_FOLDER/lib

cd ../include

cp -r libavcodec $DEST_FOLDER/include
cp -r libavdevice $DEST_FOLDER/include
cp -r libavfilter $DEST_FOLDER/include
cp -r libavformat $DEST_FOLDER/include
cp -r libavutil $DEST_FOLDER/include
cp -r libpostproc $DEST_FOLDER/include
cp -r libswresample $DEST_FOLDER/include
cp -r libswscale $DEST_FOLDER/include

cd ../
cd ../

echo "FFmpeg-wasm installed."
