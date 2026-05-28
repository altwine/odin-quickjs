#!/bin/bash
set -e
cd "$(dirname "$0")"

# clean
rm -rf ./odin-quickjs
rm -rf ./quickjs-amalgam
rm -f ./bindgen.bin

# generate bindgen executable
odin build ./bindgen/src -out:./bindgen.bin -extra-linker-flags:"-L/usr/lib/x86_64-linux-gnu -lclang"

# generate quickjs-amalgam
mkdir ./quickjs-amalgam
cd ./quickjs
make
make amalgam
unzip -o ./build/quickjs-amalgam.zip -d ../quickjs-amalgam
cd ..

# build libraries
rm -rf ./linux
mkdir ./linux
ar -M <<EOF
CREATE ./linux/libquickjs.a
ADDLIB ./quickjs/build/libqjs.a
ADDLIB ./quickjs/build/libqjs-libc.a
SAVE
END
EOF

# generate bindings
cp -f ./bindgen.sjson ./quickjs-amalgam/bindgen.sjson
./bindgen.bin ./quickjs-amalgam
cp -f ./quickjs-amalgam/output/quickjs.odin ./quickjs.odin

# fix bindings
sed -i 's/fp: \^FILE/fp: rawptr/g' ./quickjs.odin

# put them to odin-quickjs dir
mkdir ./odin-quickjs
mv -f ./linux ./odin-quickjs/linux
mv -f ./quickjs.odin ./odin-quickjs/quickjs.odin

# remove leftovers
rm -rf ./quickjs-amalgam
rm -f ./bindgen.bin
