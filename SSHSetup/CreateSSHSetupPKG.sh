#!/bin/bash
#
# Create SSH Setup PKG

set -o nounset
set -o errexit

buildPKG ()
{
# Name of the package.
pkgname="PBI-SSH-Setup"

# Once installed the identifier is used as the filename for a receipt files in /var/db/receipts/.
pkgidentifier="com.point-blank-international.pbi_ssh_client_setup"

# Package version number.
pkgversion="2.0"

# Build package.
/usr/bin/pkgbuild \
  --nopayload \
  --scripts ./scripts/ \
  --identifier "$pkgidentifier" \
  --version "$pkgversion" \
  ./PKG/"$pkgname-v$pkgversion.pkg"
}

buildPKG

exit 0
