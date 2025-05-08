#!/bin/bash
# Universal Docker Setup Script
# Creates project directory structure and handles X11 forwarding for GUI applications in Docker
# Clear the terminal

clear


GREEN='\033[0;32m'

RED='\033[0;31m'

YELLOW='\033[0;33m'

BLUE='\033[0;34m'

CYAN='\033[0;36m'

BOLD='\033[1m'

PURPLE='\033[0;35m'

NC='\033[0m' # No Color



echo -e "${BLUE}"

echo "       █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗███████╗ ██████╗██╗  ██╗ "

echo "      ██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝██╔════╝██╔════╝██║  ██║ "

echo "      ███████║██║  ██║██║   ██║███████║██╔██╗ ██║   ██║   █████╗  ██║     ███████║ "

echo "      ██╔══██║██║  ██║╚██╗ ██╔╝██╔══██║██║╚██╗██║   ██║   ██╔══╝  ██║     ██╔══██║ "

echo "      ██║  ██║██████╔╝ ╚████╔╝ ██║  ██║██║ ╚████║   ██║   ███████╗╚██████╗██║  ██║ "

echo "      ╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝ "

echo -e "${WHITE}                                  Center of Excellence${NC}"

echo

echo -e "${CYAN}  This may take a moment...${NC}"

echo

sleep 7

# Create project directory structure
echo "Creating project directory structure..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check environment variables
echo "Checking environment variables..."

MACHINE=$(uname -m)
IMAGE_TYPE=i386

IMAGE_VERSION=`cat docker-compose.yml  | grep wisedgelink/ | awk -F ':' '{print $NF}' |head -1 | tr -d '\r'`
echo "Image version: ${IMAGE_VERSION}"

case "$MACHINE" in
    x86_64)
        IMAGE_TYPE=i386
        ;;
    armv7l|aarch64)
        IMAGE_TYPE=arm32v7
        ;;
    *)
        # 默认情况（相当于 switch 语句中的 default）
        ;;
esac

# Start Docker containers
echo "Starting Docker containers..."
if command_exists docker-compose; then
    echo "Using docker-compose command..."
    docker-compose pull wisedgelink_$IMAGE_TYPE
elif command_exists docker && command_exists compose; then
    echo "Using docker compose command..."
    docker compose pull wisedgelink_$IMAGE_TYPE
else
    echo "Error: Neither docker-compose nor docker compose commands are available."
    exit 1
fi

echo "${IMAGE_TYPE}:${IMAGE_VERSION}"

docker tag harbor.edgesync.cloud/iiot-edge-sw-containers/wisedgelink/${IMAGE_TYPE}:${IMAGE_VERSION} wisedgelink/${IMAGE_TYPE}:${IMAGE_VERSION}

# Connect to container
echo "Connecting to container..."

if command_exists apt; then
	OS_ARCH=`dpkg --print-architecture`
	PACK_EXT=deb
	PACK_NAME=`ls packages/*${OS_ARCH}.${PACK_EXT}`
	echo ${PACK_NAME}
	dpkg -i ./${PACK_NAME}
elif command_exists yum; then
    OS_ARCH=`uname -m`
	PACK_EXT=rpm
	PACK_NAME=`ls packages/*${OS_ARCH}.${PACK_EXT}`
	echo ${PACK_NAME}
	yum install ./${PACK_NAME}
else
    echo "Error: Neither apt nor yum commands are available."
    exit 1
fi
#docker exec -it advantech-l2-01 bash
