#!/bin/sh
set -efu

echo "building container as $USER"
cd

echo "setting up nix..."
curl -L https://nixos.org/nix/install | sh -s --no-daemon
. /home/nixos/.nix-profile/etc/profile.d/nix.sh

# .profile loading does not seem to work with alpine, so we have to compromise.
# 1. load Nix
echo '. /home/nixos/.nix-profile/etc/profile.d/nix.sh' >> setup-env
# 2. force Nix to use cloned checkout, rather than the default expressions in ~/.nix-defexpr
echo 'export NIX_PATH=$HOME' >> setup-env # forces to use cloned checkout rather than defexpr
# 3. send a signal to `cleanup-qemu` when done
echo 'trap "echo build done | nc cleanup-qemu 11111 2>/dev/null || echo cleanup container not running" INT TERM EXIT' >> setup-env

echo "cloning nix packages..."
git clone --depth=1 -b "$NIXPKGS_BRANCH" "$NIXPKGS_URL" nixpkgs

echo "cloning nixos-hardware..."
git clone https://github.com/NixOS/nixos-hardware.git

echo "image is ready"
