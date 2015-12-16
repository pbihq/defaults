#!/bin/bash

# Meraki Profil installieren
/usr/bin/profiles -I -F -U $USER /private/tmp/asana_webclip.mobileconfig

# PBI Zertifikate von temporärer Location löschen
rm -f /private/tmp/asana_webclip.mobileconfig

logger "Asana Webclip installiert"
exit 0