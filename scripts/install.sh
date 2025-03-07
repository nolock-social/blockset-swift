cd ~/
export SWIFT_DIR=swift-6.0.3-RELEASE-ubuntu24.04-aarch64
export SWIFT_TAR_GZ=${SWIFT_DIR}.tar.gz
wget https://download.swift.org/swift-6.0.3-release/ubuntu2404-aarch64/swift-6.0.3-RELEASE/${SWIFT_TAR_GZ}
tar xzf ${SWIFT_TAR_GZ}
export PATH=~/${SWIFT_DIR}/usr/bin:"${PATH}"
