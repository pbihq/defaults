#!/bin/bash

# Download web clips from Github repo
/usr/bin/curl https://raw.githubusercontent.com/pbihq/defaults/master/Webclips/asanawebclip.mobileconfig -o /tmp/asanawebclip.mobileconfig
/usr/bin/curl https://raw.githubusercontent.com/pbihq/defaults/master/Webclips/pbihubwebclip.mobileconfig -o /tmp/pbihubwebclip.mobileconfig

# Install web clips
/usr/bin/profiles -I -F /tmp/asanawebclip.mobileconfig
/usr/bin/profiles -I -F /tmp/pbihubwebclip.mobileconfig

# Delete mobileconfig files from temporary location
rm -f /tmp/asanawebclip.mobileconfig /tmp/pbihubwebclip.mobileconfig

logger "Asana and PBI Hub web clips have been installed."
exit 0
