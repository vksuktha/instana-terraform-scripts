#!/bin/bash

echo "Generating ssh keys"

ssh-keygen -t rsa -b 3072 -N "" -f ssh-instana -q
