cd ~/
export PLATFORM=ubuntu24.04
export PLATFORM_DIR=ubuntu2404
export ARCHITECTURE=aarch64
export SWIFT_VERSION=6.0.3
###
export SWIFT_DIR=swift-${SWIFT_VERSION}-RELEASE-${PLATFORM}-${ARCHITECTURE}
export SWIFT_TAR_GZ=${SWIFT_DIR}.tar.gz
# e.g. https://download.swift.org/swift-6.0.3-release/ubuntu2404-aarch64/swift-6.0.3-RELEASE/${SWIFT_TAR_GZ}
wget https://download.swift.org/swift-${SWIFT_VERSION}-release/${PLATFORM_DIR}-${ARCHITECTURE}/swift-${SWIFT_VERSION}-RELEASE/${SWIFT_TAR_GZ}
tar xzf ${SWIFT_TAR_GZ}
export PATH=~/${SWIFT_DIR}/usr/bin:"${PATH}"
