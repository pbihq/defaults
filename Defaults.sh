#!/bin/bash -u

# Point Blank macOS and application defaults.

## Define variables
readonly seriennummer=$(system_profiler SPHardwareDataType | awk '/Serial Number/ { print $4 }')
readonly mitarbeiter=$(id -F)

## Ask for some user input at the beginning
clear
echo "Starte Point Blank-Defaults-Setup..."
echo
read -p "Wie lautet die Point Blank-Inventarnummer des Macs [$seriennummer]? " inventarnummer
	while [[ -z "$inventarnummer"  ]]; do
    	inventarnummer=$seriennummer
	done
echo
read -p "Wie lauten die eindeutigen Initialen von $mitarbeiter bei Point Blank (z. B. RTh oder TW)? " initialen
	while [[ -z "$initialen"  ]]; do
    	initialen="FREI"
	done
echo
read -p "Unter welcher Telefondurchwahl ist $mitarbeiter im Büro zu erreichen (z.B. 19)? " durchwahl_eingabe
	if [[ -z "$durchwahl_eingabe" ]]; then
		durchwahl=""
	else
		durchwahl=$(echo "| #$durchwahl_eingabe")
	fi
echo
sudo -v
clear

## Keep-alive: update existing 'sudo' time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

## Setup Apple Remote Desktop
# Give access only to pbimaintenance and show ard menu on the client machine so users can tell if you are observing or controling
echo "Setting up Apple Remote Desktop..."

# Check for local maintenance account
if [[ $(id pbmaintenance 2> /dev/null) ]]; then
	maintenanceUser=pbmaintenance
elif [[ $(id pbimaintenance 2> /dev/null) ]]; then
	maintenanceUser=pbimaintenance
else
	echo "Error: No Point Blank maintenance user account found."
fi

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -specifiedUsers
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -access -on -privs -all -users "$maintenanceUser"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setmenuextra -menuextra yes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -menu

logger "Point Blank Setup Setup User + ARD config installed"
echo "Point Blank Setup Setup User + ARD config installed"

# Point Blank Maintenance ausblenden
sudo dscl . create /Users/"$maintenanceUser" IsHidden 1

# Login-Bildschirm konfigurieren
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "www.point-blank.net"
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 3
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool YES

# Sync EFI login screen with com.apple.loginwindow
sudo rm -f /System/Library/Caches/com.apple.corestorage/EFILoginLocalizations/*.efires
# Throws an error as of 10.11
#sudo touch /System/Library/PrivateFrameworks/EFILogin.framework/Resources/EFIResourceBuilder.bundle/Contents/Resources

# Deactivate fast user switching and guest account
# 2016/07 Now managed by configuration profile
# sudo /usr/bin/defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool NO
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO

# Softwareupdates automatisch herunterladen und installieren
sudo softwareupdate --schedule on

# 2016/12 Now managed by configuration profile
# sudo /usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool YES
# sudo /usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool YES

logger "Point Blank Setup Setup ARD v1.0 installed"
echo "Point Blank Setup Setup ARD v1.0 installed"

#### Systemeinstellungen

## Activate Firewall and allow signed apps only
# 2016/10 Now managed by configuration profile (macOS 10.12+)
# sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
# sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on

## Hostnamen für den Mac im Netzwerk definieren
sudo scutil --set ComputerName "$inventarnummer-$initialen"
sudo scutil --set LocalHostName "$inventarnummer-$initialen"
sudo scutil --set HostName "$inventarnummer-$initialen"
sudo /usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$inventarnummer-$initialen"
dscacheutil -flushcache

## NTP Setup
sudo systemsetup -setnetworktimeserver utm.point-blank-international.com

## Bildschirmschoner
# 2016/07 Now managed by configuration profile
# /usr/bin/defaults write com.apple.screensaver askForPassword -bool YES
# /usr/bin/defaults write com.apple.screensaver askForPasswordDelay -int 5
# /usr/bin/defaults write com.apple.screensaver idleTime -int 0

## Energiesparen
sudo pmset -b sleep 15 displaysleep 5
sudo pmset -c sleep 60 displaysleep 15

# Lautstärke auf drei Balken einstellen
osascript -e "set volume output volume 19"

# Textkorrektur
# 2016/07 Now managed by configuration profile
#/usr/bin/defaults write -g NSAutomaticSpellingCorrectionEnabled -bool NO

#Trackpad
# Tap to click.
# /usr/bin/defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
/usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool YES
sudo /usr/bin/defaults write /Library/Preferences/.GlobalPreferences com.apple.mouse.tapBehavior -int 1

# Prozent in Menüleiste anzeigen
# 2016/07 Now managed by configuration profile
# /usr/bin/defaults write com.apple.menuextra.battery.plist ShowPercent -string "YES"

# Details in Druckerfenster anzeigen
# Does no longer work as of 10.9
#/usr/bin/defaults write -g PMPrintingExpandedStateForPrint2 -bool YES

# Set default save location to Mac.
# 2016/07 Now managed by configuration profile
#/usr/bin/defaults write -g NSDocumentSaveNewDocumentsToCloud -bool NO

# Lautlos klicken. Does not work on 2016 MacBook Pro generation
/usr/bin/defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 1

## Safari

# Startseite auf hub.pbi.online setzen
# 2016/07 Does not work on El Capitan anymore
# /usr/bin/defaults write com.apple.Safari HomePage http://hub.pbi.online

#Neuer Tab / neues Fenster zeigt Homepage
/usr/bin/defaults write com.apple.Safari NewTabBehavior -int 0
/usr/bin/defaults write com.apple.Safari NewWindowBehavior -int 0

#Favoritenleiste in Safari einblenden
/usr/bin/defaults write com.apple.Safari ShowFavoritesBar-v2 -bool YES

# Prevent Safari from opening ‘safe’ files automatically after downloading
# 2016/07 Now managed by configuration profile
# /usr/bin/defaults write com.apple.Safari AutoOpenSafeDownloads -bool NO

#### Kontakte
/usr/bin/defaults write com.apple.AddressBook ABNameSortingFormat -string "sortingFirstName sortingLastName"
/usr/bin/defaults write com.apple.AddressBook ABBirthDayVisible -int 1

#### Kalender
# Day starts at: (minutes)
/usr/bin/defaults write com.apple.iCal "first minute of work hours" -int 480
# Day ends at: (minutes)
/usr/bin/defaults write com.apple.iCal "last minute of work hours" -int 1200
# Show 16 hours at a time.
/usr/bin/defaults write com.apple.iCal "number of hours displayed" -int 16

## 2016/12 Now managed by configuration profile
# Show Birthdays calendar.
# /usr/bin/defaults write com.apple.iCal "display birthdays calendar" -bool YES
# Turn on time zone support
# /usr/bin/defaults write com.apple.iCal "TimeZone support enabled" -bool YES
# Kalenderwochen anzeigen
# /usr/bin/defaults write com.apple.iCal "Show Week Numbers" -bool YES

##### Nachrichten
/usr/bin/defaults write com.apple.iChat.plist Unified.EnableGroups -bool No
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages array" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages:0 string 'Wall Street $durchwahl'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages:3 string 'Feld'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages:4 string 'Homeoffice'" ~/Library/Preferences/com.apple.iChat.plist

/usr/libexec/PlistBuddy -c "Add :CustomAwayMessages array" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAwayMessages:0 string 'Feld'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAwayMessages:1 string 'Mittagspause'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAwayMessages:2 string 'IT-Support'" ~/Library/Preferences/com.apple.iChat.plist

# /usr/libexec/PlistBuddy -c "Add :menuExtras array" ~/Library/Preferences/com.apple.systemuiserver.plist
/usr/libexec/PlistBuddy -c "Add :menuExtras:0 string '/System/Library/CoreServices/Menu Extras/Bluetooth.menu'" ~/Library/Preferences/com.apple.systemuiserver.plist
/usr/libexec/PlistBuddy -c "Add :menuExtras:0 string '/System/Library/CoreServices/Menu Extras/Volume.menu'" ~/Library/Preferences/com.apple.systemuiserver.plist

#### Mail
/usr/bin/defaults write com.apple.mail AddInvitationsToICalAutomatically -bool NO
# If outgoing server is unavailable automatically try sending later.
/usr/bin/defaults write com.apple.mail SuppressDeliveryFailure -int 1
/usr/bin/defaults write com.apple.mail MailSound -string ""
/usr/bin/defaults write com.apple.mail JunkMailBehavior -int 0
/usr/bin/defaults write com.apple.mail AddressDisplayMode -int 3
/usr/bin/defaults write com.apple.mail ShowBccHeader -int 1
/usr/bin/defaults write com.apple.mail ShowHeaderDetails -bool YES

#### Skype Plugin
# 2016/07 Now managed by configuration profile
# /usr/bin/defaults write com.ecamm.CallRecorder AUTO_RECORD -bool YES
# /usr/bin/defaults write com.ecamm.CallRecorder DISCARD_SECONDS -int 5
# /usr/bin/defaults write com.ecamm.CallRecorder DISCARD_SHORT_CALLS -bool YES
# /usr/bin/defaults write com.ecamm.CallRecorder AUDIO_ONLY -bool YES
# /usr/bin/defaults write com.ecamm.CallRecorder VIDEO_QUALITY2 -int 1

#### Tunnelblick defaults v1.1

# Don't check for IP address changes
#/usr/bin/defaults write net.tunnelblick.tunnelblick askedUserIfOKToCheckThatIPAddressDidNotChangeAfterConnection -bool YES

# Don't send anonymized user profile
#/usr/bin/defaults write net.tunnelblick.tunnelblick SUSendProfileInfo -bool NO

# Check for and download updates automatically
#/usr/bin/defaults write net.tunnelblick.tunnelblick SUEnableAutomaticChecks -bool YES
#/usr/bin/defaults write net.tunnelblick.tunnelblick SUAutomaticallyUpdate -bool YES
#/usr/bin/defaults write net.tunnelblick.tunnelblick updateAutomatically -bool YES
#/usr/bin/defaults write net.tunnelblick.tunnelblick updateCheckAutomatically -bool YES

# Don't submit profile info
#/usr/bin/defaults write net.tunnelblick.tunnelblick updateSendProfileInfo -bool NO

# Don't show startup splash screen
#/usr/bin/defaults write net.tunnelblick.tunnelblick doNotShowSplashScreen -bool YES

# Only show window display when connecting
#/usr/bin/defaults write net.tunnelblick.tunnelblick connectionWindowDisplayCriteria -string "showWhenConnecting"

# Don't show window display on mouseover
#/usr/bin/defaults write net.tunnelblick.tunnelblick doNotShowNotificationWindowOnMouseover -bool YES

# Don't show disconnected window display
#/usr/bin/defaults write net.tunnelblick.tunnelblick doNotShowDisconnectedNotificationWindows -bool YES

# Ignore IP address change warning
#/usr/bin/defaults write net.tunnelblick.tunnelblick skipWarningThatIPAddressDidNotChangeAfterConnection -bool YES

## Datum in Menüleiste anzeigen
/usr/bin/defaults write com.apple.menuextra.clock DateFormat -string "EEE d. MMM  HH:mm"

## Set the icon size of Dock items to 36 pixels
# 2016/08 Now set by configuration profile
# /usr/bin/defaults write com.apple.dock tilesize -int 36

## Set a default program for a fileytpe, i.e. MP3 and WAV to open in Quicktime
# /usr/bin/defaults write com.apple.LaunchServices LSHandlers -array-add \
# 	'{LSHandlerContentType = "public.mp3"; LSHandlerRoleAll = "com.apple.quicktimeplayerx";}'
# /usr/bin/defaults write com.apple.LaunchServices LSHandlers -array-add \
# 	'{LSHandlerContentType = "com.microsoft.waveform-audio"; LSHandlerRoleAll = "com.apple.quicktimeplayerx";}'

## Disable Time Machine's pop-up message whenever an external drive is plugged in
sudo /usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool YES

# Disable automatic iPhone synchronisation in iTunes
/usr/bin/defaults -currentHost write com.apple.iTunes dontAutomaticallySyncIPods -bool YES

# Prevent Photos from opening up automatically when iPhone is plugged in
/usr/bin/defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES
/usr/bin/defaults -currentHost write com.apple.Photos disableHotPlug -bool YES

# Setup Touch Bar with brightness, volume, mute and screen lock buttons
/usr/bin/defaults write ~/Library/Preferences/com.apple.controlstrip MiniCustomized \
'(com.apple.system.brightness, com.apple.system.volume, com.apple.system.mute, com.apple.system.screen-lock)'

### Temporatily removed due to unresolved problem. Please start this script manually during setup
# Install Point Blank SignatureLaunchAgent
#bash <(curl -s https://raw.githubusercontent.com/pbihq/defaults/master/Signature/SignatureLaunchAgent.sh)

# Install latest version of Point Blank 'Status' script
bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/Status/InstallStatus.sh)

# Activates "Require a password to unlock each System Preferences pane"
/usr/bin/security authorizationdb read system.preferences > /tmp/system.preferences.plist
/usr/bin/defaults write /tmp/system.preferences.plist shared -bool NO
/usr/bin/security authorizationdb write system.preferences < /tmp/system.preferences.plist
/bin/rm -f /tmp/system.preferences.plist

## Change user picture
# 1. Curl Point Blank user pictures tifs from web source into /Library/User\ Pictures/Point-Blank
#sudo dscl . delete /Users/$USER jpegphoto
#sudo dscl . delete /Users/$USER picture
#sudo dscl . create /Users/$USER picture "/Library/User\ Pictures/Point-Blank/$USER.tif"
#  This forces the system to rebuild the system caches along with the local directory cache.
#sudo kextcache -system-caches

## El Capitan: Change login background picture
# Simply replace /Library/Caches/com.apple.desktop.admin.png

echo "Systemeinstellungen gesetzt."

### Kill affected applications
declare -ra app=(\
	"Activity Monitor"
	"Address Book"
	"Calendar"
	"Contacts"
	"Dock"
	"Finder"
	"Mail"
	"Messages"
	"Safari"
	"SystemUIServer"
	"iCal"
	"ControlStrip"
	"cfprefsd"
	)

for app in "${app[@]}"
do
	killall "$app" &> /dev/null
done

echo "Point Blank Defaults wurden installiert. Bitte Mac neustarten!"
echo
logger "Point Blank Defaults wurden installiert."

osascript -e 'tell app "loginwindow" to «event aevtrrst»'
exit 0
