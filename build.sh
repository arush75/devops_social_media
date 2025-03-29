#!/bin/bash

REMOTE_SERVER="root@192.168.106.129"
REMOTE_PATH="/root/"
REMOTE_TAR="/root/djangoproj-1.tar.gz"  # The tarball's name now as djangoproj-1.tar.gz
IMAGE_NAME="djangoproj:1"  # Set the image name and tag to "djangoproj:1"
BUILD_CONTEXT="."  # Use the current directory as the build context
TAR_PATH="./djangoproj-1.tar.gz"  # Path for tarball in the current directory

echo "Starting Docker Build Process..."
cd "$(dirname "$0")" || { echo "Failed to change directory to the script location"; exit 1; }

# Remove old tarball if exists
if [ -f "$TAR_PATH" ]; then
    echo "Removing old local tarball..."
    rm -f "$TAR_PATH"
fi

# Remove old Docker image if exists
echo "Removing old Docker image if it exists..."
docker rmi -f "$IMAGE_NAME" || echo "No old Docker image found."

# Clean Docker system to free space before building
echo "Cleaning up Docker system to free space..."
docker system prune -a --volumes -f
sync && echo 3 > /proc/sys/vm/drop_caches

# Build Docker image
echo "Building Docker Image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" "$BUILD_CONTEXT"
if [ $? -ne 0 ]; then
    echo "Docker build failed! Check the Dockerfile and build context."
    exit 1
fi

# Save Docker image as a tarball
echo "Saving Docker Image as $TAR_PATH"
docker save -o "$TAR_PATH" "$IMAGE_NAME"
if [ ! -f "$TAR_PATH" ]; then
    echo "Docker image not saved! Check for errors."
    exit 1
fi

# Check if the tarball exists on the remote Docker VM and remove if it exists
echo "Checking for existing tarball on Docker VM..."
ssh -o StrictHostKeyChecking=no "$REMOTE_SERVER" "if [ -f '$REMOTE_TAR' ]; then echo 'Removing old backup...'; rm -f '$REMOTE_TAR'; fi"

# Transfer Docker image tarball to the remote Docker VM
echo "Transferring Docker Image to $REMOTE_SERVER"
scp -o StrictHostKeyChecking=no "$TAR_PATH" "$REMOTE_SERVER:$REMOTE_PATH"
if [ $? -ne 0 ]; then
    echo "SCP transfer failed! Check SSH connection."
    exit 1
fi

# Clean up tarball from agent VM after successful transfer
echo "Cleaning up tarball from agent VM..."
rm -f "$TAR_PATH"

# Remove the Docker image locally after successful transfer
echo "Removing Docker image from local after transfer..."
docker rmi -f "$IMAGE_NAME" || echo "No image to remove locally."

# Clean up Docker system again to reclaim space
echo "Cleaning up Docker system again to free up space..."
docker system prune -a --volumes -f
sync && echo 3 > /proc/sys/vm/drop_caches

echo "Build and transfer completed successfully!"
