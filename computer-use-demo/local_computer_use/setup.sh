#!/bin/bash

set -e

# Update and upgrade system packages
sudo apt-get update && \
sudo apt-get -y upgrade

# Install build essentials and UI requirements
sudo apt-get -y install \
    build-essential \
    xvfb \
    xterm \
    xdotool \
    scrot \
    imagemagick \
    sudo \
    mutter \
    x11vnc \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    git \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    net-tools \
    netcat \
    software-properties-common

# Add PPA for Mozilla team (if not already added)
sudo add-apt-repository -y ppa:mozillateam/ppa

# Install userland applications
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    libreoffice \
    firefox-esr \
    x11-apps \
    xpdf \
    gedit \
    xpaint \
    tint2 \
    galculator \
    pcmanfm \
    unzip

# Clean up
sudo apt-get clean

# Install noVNC
if [ ! -d "/opt/noVNC" ]; then
    sudo git clone --branch v1.5.0 https://github.com/novnc/noVNC.git /opt/noVNC
    sudo git clone --branch v0.12.0 https://github.com/novnc/websockify /opt/noVNC/utils/websockify
    sudo ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html
fi

# Set up pyenv environment variables
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Install pyenv
if [ ! -d "$PYENV_ROOT" ]; then
    git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
    cd "$PYENV_ROOT" && src/configure && make -C src
fi

# Update shell configuration
if ! grep -q 'export PYENV_ROOT' ~/.bashrc; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
fi

# Reload shell configuration
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Install specific Python version using pyenv
PYTHON_VERSION_MAJOR=3
PYTHON_VERSION_MINOR=11
PYTHON_VERSION_PATCH=6
PYTHON_VERSION="$PYTHON_VERSION_MAJOR.$PYTHON_VERSION_MINOR.$PYTHON_VERSION_PATCH"

if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
    pyenv install "$PYTHON_VERSION"
fi
pyenv global "$PYTHON_VERSION"
pyenv rehash

# Upgrade pip, setuptools, and wheel
python -m pip install --upgrade pip==23.1.2 setuptools==58.0.4 wheel==0.40.0

# Configure pip to disable version check
python -m pip config set global.disable-pip-version-check true

# Activate your virtual environment
source ~/venv/bin/activate

# Install Python dependencies
pip install -r computer_use_demo/requirements.txt

echo "Setup complete. You can now run your application."