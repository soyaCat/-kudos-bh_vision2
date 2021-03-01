#!/bin/bash

# clean build
if [ "$1" == "clean" ]; then
    #docker builder prune
    docker build --no-cache --build-arg HOST_USER=$USER --tag 'ros_kinect_full' .
else 
    docker build --build-arg HOST_USER=$USER --tag 'ros_kinect_full' .
fi

