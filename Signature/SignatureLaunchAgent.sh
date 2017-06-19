#!/bin/bash

echo "<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>online.pbi.startup.signature</string>
	<key>ProcessType</key>
	<string>Background</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/bash</string>
		<string>-c</string>
		<string>ping -c 1 8.8.8.8 &amp;&gt; /dev/null &amp;&amp; curl -s https://raw.githubusercontent.com/pbihq/defaults/master/Signature/SignatureSetter.sh | bash -s -- || sleep 600; ping -c 1 8.8.8.8 &amp;&gt; /dev/null &amp;&amp; curl -s https://raw.githubusercontent.com/pbihq/defaults/master/Signature/SignatureSetter.sh | bash -s --</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StandardErrorPath</key>
	<string>/tmp/online.pbi.startup.signature.stderr</string>
	<key>StandardOutPath</key>
	<string>/tmp/online.pbi.startup.signature.stdout</string>
	<key>StartInterval</key>
	<integer>21600</integer>
</dict>
</plist>" > ~/Library/LaunchAgents/online.pbi.startup.signature.plist

chmod 644 ~/Library/LaunchAgents/online.pbi.startup.signature.plist

exit 0
