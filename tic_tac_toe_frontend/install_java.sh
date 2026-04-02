#!/bin/bash
set -e

# Install OpenJDK 25 alongside existing Java 17 and pin 17 as default
# This script is intended to run as root on the Flutter dev image.

ARCH=$(dpkg --print-architecture)
JAVA17_HOME="/usr/lib/jvm/java-17-openjdk-${ARCH}"
JAVA25_HOME="/usr/lib/jvm/java-25-openjdk-${ARCH}"

echo "=== Installing OpenJDK 25 (arch: ${ARCH}) ==="

apt-get update
apt-get install -y --no-install-recommends openjdk-25-jdk
rm -rf /var/lib/apt/lists/*

echo "=== Pinning Java 17 as default via update-alternatives ==="

update-alternatives --set java  "${JAVA17_HOME}/bin/java"
update-alternatives --set javac "${JAVA17_HOME}/bin/javac"

echo "=== Updating /etc/profile.d/java.sh ==="

cat > /etc/profile.d/java.sh << EOF
export JAVA_HOME=${JAVA17_HOME}
export JAVA17_HOME=${JAVA17_HOME}
export JAVA25_HOME=${JAVA25_HOME}
EOF
chmod +x /etc/profile.d/java.sh

echo "=== Verifying installation ==="

echo "Default java:"
java -version 2>&1 | head -1

echo "Java 25:"
"${JAVA25_HOME}/bin/java" -version 2>&1 | head -1

echo "=== Done. Java 25 available at \$JAVA25_HOME (${JAVA25_HOME}) ==="
echo "=== Default remains Java 17. Switch per-project with: export JAVA_HOME=\$JAVA25_HOME ==="
