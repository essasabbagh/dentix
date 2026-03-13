#!/bin/bash

# Compress JPG/JPEG files with jpegoptim (lossless by default)
# Mac install: brew install jpegoptim
find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -exec jpegoptim --preserve --strip-all {} \;

# Compress PNG files with pngquant (near-lossless)
# Mac install: brew install pngquant
find . -type f -iname "*.png" -exec pngquant --ext .png --force --skip-if-larger --quality 80-100 {} \;

# Compress SVG files with svgo
# Mac install: npm install -g svgo   (requires Node.js, install with: brew install node)
find . -type f -iname "*.svg" -exec svgo --multipass {} \;
