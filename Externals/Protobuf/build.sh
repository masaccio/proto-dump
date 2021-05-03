#!/bin/bash

# Build adapted from Bennett Smith's work at https://gist.github.com/BennettSmith/7150245
# Main additions are limiting build to x86_64 and arm64 on macOS

exec 3>&1 4>&2 >build.log 2>&1

function fatal_error {
  echo $(tput setaf 1)"*** Build failed: examine build.log" $(tput sgr0) >&3
  exit 1
}

echo $(tput setaf 2)"*** Logging to build.log" $(tput sgr0) >&3
echo $(tput setaf 2)"*** Unpacking protobuf-2.5.0" $(tput sgr0) >&3
rm -rf protobuf-2.5.0 platform
tar zxf packages/protobuf-2.5.0.tar.gz || fatal_error
patch -s -d protobuf-2.5.0 -p1 <packages/0001-Add-generic-GCC-support-for-atomic-operations.patch || fatal_error
patch -s -d protobuf-2.5.0 -p1 < packages/0001-Add-generic-gcc-header-to-Makefile.am.patch || fatal_error

# Set this to the replacement name for the 'google' namespace.
# This is being done to avoid a conflict with the private
# framework build of Google Protobuf that Apple ships with their
# OpenGL ES framework.
GOOGLE_NAMESPACE=google_public

ROOTDIR=`pwd`
PREFIX=${ROOTDIR}
mkdir -p ${PREFIX}/platform

EXTRA_MAKE_FLAGS="-j4"

CC=clang
CFLAGS="-DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions -Wno-unused-local-typedef -Wno-deprecated-declarations -Wno-unused-function -Wno-unused-const-variable"
CXX=clang
CXXFLAGS="${CFLAGS} -std=c++11 -stdlib=libc++"
LDFLAGS="-stdlib=libc++"
LIBS="-lc++ -lc++abi"

echo $(tput setaf 2)"*** Patching protobuf-2.5.0" $(tput sgr0) >&3
cd ${ROOTDIR}/protobuf-2.5.0/src/google/protobuf
sed -i '' -e "s/namespace\ google /namespace\ ${GOOGLE_NAMESPACE} /g" $(find . -name \*.h -type f) || fatal_error
sed -i '' -e "s/namespace\ google /namespace\ ${GOOGLE_NAMESPACE} /g" $(find . -name \*.cc -type f) || fatal_error
sed -i '' -e "s/namespace\ google /namespace\ ${GOOGLE_NAMESPACE} /g" $(find . -name \*.proto -type f) || fatal_error
sed -i '' -e "s/google::protobuf/${GOOGLE_NAMESPACE}::protobuf/g" $(find . -name \*.h -type f) || fatal_error
sed -i '' -e "s/google::protobuf/${GOOGLE_NAMESPACE}::protobuf/g" $(find . -name \*.cc -type f) || fatal_error
sed -i '' -e "s/google::protobuf/${GOOGLE_NAMESPACE}::protobuf/g" $(find . -name \*.proto -type f) || fatal_error

echo $(tput setaf 2)"*** Configuring for x86_64" $(tput sgr0) >&3
cd ${ROOTDIR}/protobuf-2.5.0
./configure --disable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX}/platform/x86_64 "CC=${CC}" "CFLAGS=${CFLAGS} -arch x86_64" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch x86_64" "LDFLAGS=${LDFLAGS}" "LIBS=${LIBS}" || fatal_error

echo $(tput setaf 2)"*** Building for x86_64" $(tput sgr0) >&3
make ${EXTRA_MAKE_FLAGS} install || fatal_error
(cd python && python setup.py build && python setup.py install --user) || fatal_error

X86_64_MAC_PROTOBUF=x86_64/lib/libprotobuf.a
X86_64_MAC_PROTOBUF_LITE=x86_64/lib/libprotobuf-lite.a

echo $(tput setaf 2)"*** Configuring for arm64" $(tput sgr0) >&3
cd ${ROOTDIR}/protobuf-2.5.0
make distclean || fatal_error
./configure --build=x86_64-apple-darwin13.0.0 --host=arm --with-protoc=${PREFIX}/platform/x86_64/bin/protoc --disable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX}/platform/arm64 "CC=${CC}" "CFLAGS=${CFLAGS} -arch arm64" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch arm64" LDFLAGS="-arch arm64 ${LDFLAGS}" "LIBS=${LIBS}" || fatal_error

echo $(tput setaf 2)"*** Building for arm64" $(tput sgr0) >&3
make ${EXTRA_MAKE_FLAGS} install || fatal_error

ARM64_MAC_PROTOBUF=arm64/lib/libprotobuf.a 
ARM64_MAC_PROTOBUF_LITE=arm64/lib/libprotobuf-lite.a 

echo $(tput setaf 2)"*** Create Universal Libraries" $(tput sgr0) >&3
cd ${PREFIX}/platform
mkdir universal
lipo ${X86_64_MAC_PROTOBUF} ${ARM64_MAC_PROTOBUF} -create -output universal/libprotobuf.a || fatal_error
lipo ${X86_64_MAC_PROTOBUF_LITE} ${ARM64_MAC_PROTOBUF_LITE} -create -output universal/libprotobuf-lite.a || fatal_error

echo $(tput setaf 2)"*** Packaging" $(tput sgr0) >&3
cd ${PREFIX}
rm -rf prebuilt
mkdir -p prebuilt/bin prebuilt/lib prebuilt/include
cp platform/x86_64/bin/protoc prebuilt/bin || fatal_error
cp -r platform/x86_64/lib/* prebuilt/lib || fatal_error
cp -r platform/universal/* prebuilt/lib || fatal_error
cp -r include/google prebuilt/include || fatal_error

rm -rf platform protobuf-2.5.0 include

file prebuilt/lib/libprotobuf.a >&3

echo $(tput setaf 2)"*** Done!" $(tput sgr0) >&3
