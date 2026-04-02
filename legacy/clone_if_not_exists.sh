#!/bin/bash

repo_url=$1
clone_path=$2

if [ ! -d $clone_path ] ; then
    git clone $repo_url $clone_path
else
    echo "Directory already exists, omitting..."
fi
