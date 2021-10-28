#!/bin/sh
set -e

FFMPEG_VERSION=4.3.2
X264_VERSION=20170226-2245-stable

mkdir -p build
PREFIX=${PWD}/build

VERSION_FILE="${PREFIX}/built_versions.txt"
VERSION_STR="FFMPEG_VERSION=${FFMPEG_VERSION} X264_VERSION=${X264_VERSION}"

if [ -f $VERSION_FILE ]; then
    # echo "versions exist."
    BUILT_VERSION_STR=$(cat $VERSION_FILE)
    # echo "Built-versions = $BUILT_VERSION_STR"
    # echo "Current-versions = $VERSION_STR"
    if [ "$BUILT_VERSION_STR" == "$VERSION_STR" ]; then
        echo "Skipping ffmpeg-wasm-build: already built"
        exit
    fi
fi

MAKEFLAGS="-j4"

# Dev-Dependencies: autoconf libtool build-essential

rm -rf build
mkdir build
rm -rf tmp
mkdir tmp
cd tmp

# Download and build x264.
echo "Downloading x264..."
wget https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 \
    && tar xvfj x264-snapshot-${X264_VERSION}.tar.bz2 \
    && rm x264-snapshot-${X264_VERSION}.tar.bz2

echo "Configuring x264..."
cd x264-snapshot-${X264_VERSION}
emconfigure ./configure \
  --prefix=${PREFIX} \
  --host=i686-gnu \
  --enable-static \
  --disable-cli \
  --disable-asm \
  --extra-cflags="-s USE_PTHREADS=1"

echo "Building x264..."
emmake make

echo "Installing x264..."
emmake make install 

cd ..

# Download ffmpeg release source.

echo "Downloading ffmpeg..."
wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz \
  && tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz \
  && rm ffmpeg-${FFMPEG_VERSION}.tar.gz

CFLAGS="-s USE_PTHREADS=1 -O3 -I${PREFIX}/include"
LDFLAGS="$CFLAGS -L${PREFIX}/lib -s INITIAL_MEMORY=33554432"

# Configure and build FFmpeg with emscripten.
# Disable all programs and only enable features we will use.
# https://github.com/FFmpeg/FFmpeg/blob/master/configure
echo "Configuring ffmpeg..."
cd ffmpeg-${FFMPEG_VERSION}
emconfigure ./configure \
  --prefix=${PREFIX} \
  --target-os=none \
  --arch=x86_32 \
  --enable-cross-compile \
  --disable-debug \
  --disable-x86asm \
  --disable-inline-asm \
  --disable-stripping \
  --disable-programs \
  --disable-doc \
  --disable-all \
  --enable-avcodec \
  --enable-avformat \
  --enable-avfilter \
  --enable-avdevice \
  --enable-avutil \
  --enable-swresample \
  --enable-postproc \
  --enable-swscale \
  --enable-filters \
  --enable-protocol=file \
  --enable-decoder=h264,aac,pcm_s16le \
  --enable-demuxer=mov,matroska \
  --enable-muxer=mp4 \
  --enable-gpl \
  --enable-libx264 \
  --extra-cflags="$CFLAGS" \
  --extra-cxxflags="$CFLAGS" \
  --extra-ldflags="$LDFLAGS" \
  --nm="llvm-nm -g" \
  --ar=emar \
  --ranlib=llvm-ranlib \
  --cc=emcc \
  --cxx=em++ \
  --objcc=emcc \
  --dep-cc=emcc
#  --as=llvm-as

echo "Building ffmpeg..."
emmake make -j4 
echo "Installing ffmpeg..."
emmake make install

cd ..
cd ..

echo $VERSION_STR > $VERSION_FILE
