#!/bin/bash

# Installs Webclips
/usr/bin/profiles -I -F /tmp/filevaultprotection.mobileconfig

# Remove Mobileconfig-Files from temporary location
rm -f /tmp/filevaultprotection.mobileconfig

logger "FileVault Protection has been installed."
exit 0
