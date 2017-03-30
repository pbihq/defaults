#!/bin/bash

# Download and install web clips from Github repo
/usr/bin/curl --silent https://raw.githubusercontent.com/pbihq/defaults/master/Webclips/WebClipHub.mobileconfig | \
/usr/bin/profiles -I -F - || { /bin/echo "Error installing Web Clip Hub"; exit 1; }

/usr/bin/curl --silent https://raw.githubusercontent.com/pbihq/defaults/master/Webclips/WebClipAsana.mobileconfig | \
/usr/bin/profiles -I -F - || { /bin/echo "Error installing Web Clip Asana"; exit 1; }

logger "Web Clips for Hub and Asana have been successfully installed."
echo "Web Clips for Hub and Asana have been successfully installed."
exit 0
