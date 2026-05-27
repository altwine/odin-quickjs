#!/bin/bash
set -e

# clean
rm -rf ./quickjs-amalgam
rm -rf ./linux
rm -f ./bindgen.bin
rm -f ./quickjs.odin

# generate bindgen executable
odin build ./bindgen/src -out:./bindgen.bin

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

# remove leftovers
rm -rf ./quickjs-amalgam
rm -f ./bindgen.bin
