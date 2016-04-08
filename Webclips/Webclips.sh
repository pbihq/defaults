#!/bin/bash

# Download web clips from Github repo
/usr/bin/curl https://raw.githubusercontent.com/pbihq/defaults/master/Webclips/pbihubwebclip.mobileconfig -o /tmp/pbihubwebclip.mobileconfig
/usr/bin/curl https://raw.githubusercontent.com/pbihq/defaults/master/Webclips/asanawebclip.mobileconfig -o /tmp/asanawebclip.mobileconfig

# Install web clips
/usr/bin/profiles -I -F /tmp/pbihubwebclip.mobileconfig
/usr/bin/profiles -I -F /tmp/asanawebclip.mobileconfig

# Delete mobileconfig files from temporary location
rm -f /tmp/pbihubwebclip.mobileconfig /tmp/asanawebclip.mobileconfig

logger "PBI Hub and Asana web clips have been installed."
exit 0
