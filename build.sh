#!/bin/bash
cd /root/ansible

# Build the Docker image locally
docker build -t $JOB_NAME:$BUILD_ID .

# Save the Docker image as a tarball for transfer
docker save -o $JOB_NAME-$BUILD_ID.tar.gz $JOB_NAME:$BUILD_ID

# Move Docker image to Docker VM
scp -o StrictHostKeyChecking=no $JOB_NAME-$BUILD_ID.tar.gz root@192.168.106.129:/root/
