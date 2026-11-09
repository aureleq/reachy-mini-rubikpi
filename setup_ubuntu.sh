#!/usr/bin/env bash
set -e

sudo apt-get update

# OpenCL ICD needed by some Ubuntu multimedia dependencies
sudo apt-get install -y \
    ocl-icd-libopencl1

# Build + PyGObject dependencies
sudo apt-get install -y \
    build-essential \
    pkg-config \
    python3-dev \
    libcairo2-dev \
    libgirepository1.0-dev \
    libgirepository-2.0-dev \
    libglib2.0-dev \
    libffi-dev \
    libssl-dev

# Reachy Mini / GStreamer dependencies
sudo apt-get install -y \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    libportaudio2 \
    libnice10 \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-base-apps \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-alsa \
    gstreamer1.0-nice \
    python3-gi \
    python3-gi-cairo

echo "Ubuntu dependencies installed."
echo "Now run: uv sync"
