xcodebuild VALID_ARCHS=`arch` ONLY_ACTIVE_ARCH=YES -configuration Release -project proto-dump.xcodeproj -target proto-dump clean
xcodebuild VALID_ARCHS=`arch` ONLY_ACTIVE_ARCH=YES -configuration Release -project proto-dump.xcodeproj -target proto-dump build
xcodebuild VALID_ARCHS=`arch` ONLY_ACTIVE_ARCH=YES -configuration Release -project proto-dump.xcodeproj -target ProtoDumpUnitTests build
xcodebuild VALID_ARCHS=`arch` ONLY_ACTIVE_ARCH=YES -configuration Release -project proto-dump.xcodeproj -scheme proto-dump test
