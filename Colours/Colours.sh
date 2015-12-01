#!/bin/bash
# 
# Setup PBI Colours
#
# Note: PKG installer deploys PLIST and CLR payloads to $TMPDIR

# Check for existing custom user colours and copy PLIST if they don't exist
if [[ ! -f ~/Library/Colors/NSColorPanelSwatches.plist ]]; then
	cp $TMPDIR/NSColorPanelSwatches.plist ~/Library/Colors
	rm $TMPDIR/NSColorPanelSwatches.plist
else
	rm $TMPDIR/NSColorPanelSwatches.plist
fi

# Install PBI Colours palette for current user
cp $TMPDIR/PBI\ Colours\ v1.1.clr ~/Library/Colors

exit 0