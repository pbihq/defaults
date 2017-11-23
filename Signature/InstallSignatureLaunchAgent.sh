#!/bin/bash

# Install e-mail signature LaunchAgent

# #################################################################################################
# Declare and assign global variables. Change as needed:
# #################################################################################################
# Identify the logged-in user
readonly loggedInUser="$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')"
# Path to logged in user's LaunchAgents folder
readonly launchAgentsPath="/Users/${loggedInUser}/Library/LaunchAgents"
# LaunchAgent name
readonly launchAgentName="online.pbi.startup.signature"
# #################################################################################################
# Set up logging
info()    { echo "[INFO] $*" 1> >(sed $'s,.*,\e[32m&\e[m,'); }
warning() { echo "[WARNING] $*" 1> >(sed $'s,.*,\e[33m&\e[m,'); }
error()   { echo "[ERROR] $*" 1> >(sed $'s,.*,\e[35m&\e[m,'); }
fatal()   { echo "[FATAL] $*" 1> >(sed $'s,.*,\e[31m&\e[m,'); exit 1; }
# #################################################################################################
# Set unofficial Bash strict mode
# Source: https://dev.to/thiht/shell-scripts-matter
set -euo pipefail
IFS=$'\n\t'

# Check if operating system is macOS
function checkOS() {
  if [[ ! "$(uname)" = "Darwin" ]]; then return 1; fi
}

# Make sure script is not being run as root / with sudo
function checkRoot() {
  if [ "$EUID" -eq 0 ]; then return 1; fi
}

# Create LaunchAgents folder if it doesn't exist
function checkLaunchAgentsFolder() {
	if [[ ! -d "$launchAgentsPath" ]]; then
		mkdir -p "$launchAgentsPath"
	fi
}

# Create LaunchAgent
function installLaunchAgent() {
	cat <<- EOF > "${launchAgentsPath}/${launchAgentName}.plist"
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>$launchAgentName</string>
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
		<string>/tmp/${launchAgentName}.stderr</string>
		<key>StandardOutPath</key>
		<string>/tmp/${launchAgentName}.stdout</string>
		<key>StartInterval</key>
		<integer>21600</integer>
	</dict>
	</plist>
	EOF

	chmod 644 "${launchAgentsPath}/${launchAgentName}.plist"
}

# Execute functions
checkOS || fatal "It seems you are not running macOS. Exiting..."
checkRoot || fatal "Please do not run this script with elevated privileges"
checkLaunchAgentsFolder || fatal "Could not create folder at $launchAgentsPath"
installLaunchAgent || fatal "Error running installLaunchAgent()"
info "E-mail signature LaunchAgent '$launchAgentName' has been successfully installed at '$launchAgentsPath'"

exit 0
