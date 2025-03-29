#!/bin/bash
cd /root/ansible

# Run the Ansible playbook to load and start the Docker container on Docker VM
ansible-playbook docker.yaml
