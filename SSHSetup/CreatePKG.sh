#!/bin/bash
#
# Create SSH Setup PKG

set -o nounset
set -o errexit

# Set working directory to current directory
workDir="${0%/*}"

buildPKG ()
{
# Name of the package.
PKGName="PBI-SSH-Setup"

# Once installed the identifier is used as the filename for a receipt files in /var/db/receipts/.
PKGIdentifier="com.point-blank-international.pbi_ssh_client_setup"

# Package version number.
PKGVersion="2.0"

# Remove any unwanted .DS_Store files.
/usr/bin/find $workDir -name '*.DS_Store' -type f -delete

# Remove any extended attributes (ACEs).
/usr/bin/xattr -rc $workDir

# Build package.
/usr/bin/pkgbuild \
  --nopayload \
  --scripts $workDir/scripts \
  --identifier "$PKGIdentifier" \
  --version "$PKGVersion" \
  $workDir/build/"$PKGName-v$PKGVersion.pkg"
}

buildPKG

exit 0
