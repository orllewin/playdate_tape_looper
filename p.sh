#!/bin/bash

timestamp=$(date +%s)
echo "Saving: $timestamp"
git add .
git commit -m '$timestamp'
git push origin main