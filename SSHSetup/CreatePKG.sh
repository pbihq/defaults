#!/bin/bash

# #################################################################################################
# Create Point-Blank SSH Setup PKG
# #################################################################################################
# Set up logging
info()    { echo "[INFO] $*" 1> >(sed $'s,.*,\e[32m&\e[m,'); }
warning() { echo "[WARNING] $*" 1> >(sed $'s,.*,\e[33m&\e[m,'); }
error()   { echo "[ERROR] $*" 1> >(sed $'s,.*,\e[35m&\e[m,'); }
fatal()   { echo "[FATAL] $*" 1> >(sed $'s,.*,\e[31m&\e[m,'); exit 1; }
# #################################################################################################
# Set unofficial Bash strict mode
# Source: https://dev.to/thiht/shell-scripts-matter
set -euo pipefail
IFS=$'\n\t'

# Set working directory so that script can be run independent of location
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
# #################################################################################################

# Check if operating system is macOS
function checkOS() {
  if [[ ! "$(uname)" = "Darwin" ]]; then return 1; fi
}

# Build package
function buildPKG() {
  # Name of the package.
  PKGName="Point-Blank-SSH-Setup"

  # Once installed the identifier is used as the filename for a receipt files in /var/db/receipts/.
  PKGIdentifier="com.point-blank-international.pbi_ssh_client_setup"

  # Package version number.
  PKGVersion="2.1"

  # Remove any unwanted .DS_Store files.
  /usr/bin/find "$DIR" -name '*.DS_Store' -type f -delete

  # Remove any extended attributes (ACEs).
  /usr/bin/xattr -rc "$DIR"

  # Build package.
  /usr/bin/pkgbuild \
    --nopayload \
    --scripts "$DIR/scripts" \
    --identifier "$PKGIdentifier" \
    --version "$PKGVersion" \
    "$DIR/build/${PKGName}-v${PKGVersion}.pkg"
}

checkOS || fatal "It seems you are not running macOS. Exiting..."
buildPKG || error "Something went wrong while running buildPKG()"

exit 0
