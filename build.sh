#!/bin/bash
cd /root/ansible

# Build the Docker image using the correct context
docker build -t $JOB_NAME:$BUILD_ID /root/ansible/myprojectdata

# Save the Docker image as a tarball for transfer
docker save -o /root/ansible/$JOB_NAME-$BUILD_ID.tar.gz $JOB_NAME:$BUILD_ID

# Move Docker image to Docker VM
scp -o StrictHostKeyChecking=no /root/ansible/$JOB_NAME-$BUILD_ID.tar.gz root@192.168.106.129:/root/
