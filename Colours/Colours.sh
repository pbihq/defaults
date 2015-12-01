#!/bin/bash
# 
# Setup PBI Colours
#
# Note: PKG installer deploys PLIST and CLR payloads to /tmp

# Check for existing custom user colours and copy PLIST if they don't exist
if [[ ! -f ~/Library/Colors/NSColorPanelSwatches.plist ]]; then
	cp /tmp/NSColorPanelSwatches.plist ~/Library/Colors
	rm /tmp/NSColorPanelSwatches.plist
	chown $USER:staff ~/Library/Colors/NSColorPanelSwatches.plist
else
	rm /tmp/NSColorPanelSwatches.plist
fi

# Install PBI Colours palette for current user
cp /tmp/PBI\ Colours\ v1.1.clr ~/Library/Colors
chown $USER:staff ~/Library/Colors/PBI\ Colours\ v1.1.clr
rm /tmp/PBI\ Colours\ v1.1.clr

exit 0