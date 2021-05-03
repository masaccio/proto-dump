#! /bin/bash

exec 3>&1 4>&2 >build.log 2>&1

function fatal_error {
  echo $(tput setaf 1)"*** Build failed: examine build.log" $(tput sgr0) >&3
  exit 1
}

PROTOBUF_AR="Externals/Protobuf/prebuilt/lib/libprotobuf.a"
CLU_AR="Externals/CLU/build/Release/libCommand Line Utilities.a"
if [ ! -f "${PROTOBUF_AR}" ]; then
    echo $(tput setaf 1)*** ${PROTOBUF_AR}: archive not found$(tput sgr0) >&4
	echo $(tput setaf 2)"*** Run build.sh in Externals/Protobuf"$(tput sgr0) >&3
	exit 1
fi
if [ ! -f "${CLU_AR}" ]; then
    echo $(tput setaf 1)*** ${CLU_AR}: archive not found$(tput sgr0) >&4
	echo $(tput setaf 2)"*** Run build.sh in Externals/CLU"$(tput sgr0) >&3
	exit 1
fi

args="VALID_ARCHS=`arch` ONLY_ACTIVE_ARCH=YES -configuration Release -project proto-dump.xcodeproj"

echo $(tput setaf 2)"*** Logging to build.log" $(tput sgr0) >&3
echo $(tput setaf 2)"*** Cleaning build environment" $(tput sgr0) >&3
xcodebuild ${args} -target proto-dump clean || fatal_error "Clean failed: check build.log"

echo $(tput setaf 2)"*** Building `arch` architecture" $(tput sgr0) >&3
xcodebuild ${args} -target proto-dump build || fatal_error "Build failed: check build.log"

echo $(tput setaf 2)"*** Building unit tests" $(tput sgr0) >&3
xcodebuild ${args} -target ProtoDumpUnitTests build || fatal_error "Tests build failed: check build.log"

echo $(tput setaf 2)"*** Running unit tests" $(tput sgr0) >&3
xcodebuild ${args} -scheme proto-dump test || fatal_error "Test failed: check build.log"

echo $(tput setaf 2)"*** Build and test successful!" $(tput sgr0) >&3
echo "% build/Release/proto-dump" >&3
build/Release/proto-dump >&3
