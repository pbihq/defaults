#!/bin/bash
#
# PBI Defaults v2.3 | November 2015

## Define variables
seriennummer=$(system_profiler SPHardwareDataType | grep "Serial Number" | awk '{print $4}')
mitarbeiter=$(id -F)

## Ask for some user input at the beginning
clear
echo "Starte PBI Defaults Setup..."
echo
read -p "Wie lautet die PBI Inventarnummer des Macs [$seriennummer]? " inventarnummer
	while [[ -z "$inventarnummer"  ]]; do
    	inventarnummer=$seriennummer
	done
echo
read -p "Wie lauten die eindeutigen Initialen von $mitarbeiter bei PBI (z. B. RTh oder RTo)? " initialen
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
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -specifiedUsers
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -access -on -privs -all -users pbimaintenance
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setmenuextra -menuextra yes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -menu

logger "PBI Setup Setup User + ARD config installed"
echo "PBI Setup Setup User + ARD config installed"

# PBI Maintenance ausblenden
sudo dscl . create /Users/pbimaintenance IsHidden 1

# Login-Bildschirm konfigurieren
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "www.point-blank-international.com"
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -integer 5
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true
sudo touch /System/Library/PrivateFrameworks/EFILogin.framework/Resources/EFIResourceBuilder.bundle/Contents/Resources

# Deactivate fast user switching and guest account
sudo /usr/bin/defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

# Softwareupdates automatisch herunterladen und installieren
sudo softwareupdate --schedule on
sudo /usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
sudo /usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool true

logger "PBI Setup Setup ARD v1.0 installed"
echo "PBI Setup Setup ARD v1.0 installed"

#### Systemeinstellungen

## Activate Firewall and allow signed apps only
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on

## Hostnamen für den Mac im Netzwerk definieren
sudo scutil --set ComputerName "$inventarnummer-$initialen"
sudo scutil --set LocalHostName "$inventarnummer-$initialen"
sudo scutil --set HostName "$inventarnummer-$initialen"
sudo /usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$inventarnummer-$initialen"
dscacheutil -flushcache

## PBI NTP Setup
sudo systemsetup -setnetworktimeserver utm.point-blank-international.com

## Bildschirmschoner
/usr/bin/defaults write com.apple.screensaver askForPassword -bool true
/usr/bin/defaults write com.apple.screensaver askForPasswordDelay -int 5
/usr/bin/defaults write com.apple.screensaver idleTime -int 0

## Energiesparen
sudo pmset -b sleep 15 displaysleep 5
sudo pmset -c sleep 60 displaysleep 15

# Textkorrektur
/usr/bin/defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

#Trackpad
# Tap to click.
/usr/bin/defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
/usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo /usr/bin/defaults write /Library/Preferences/.GlobalPreferences com.apple.mouse.tapBehavior -int 1

#Prozent in Menüleiste anzeigen
/usr/bin/defaults write com.apple.menuextra.battery.plist ShowPercent -string "YES"

#Details in Druckerfenster anzeigen
/usr/bin/defaults write -g PMPrintingExpandedStateForPrint2 -bool true

#Set default save location to Mac.
/usr/bin/defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false

#Lautlos klicken
/usr/bin/defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 1

## Safari

#Startseite auf hub.point-blank-internation.com setzen
/usr/bin/defaults write com.apple.Safari HomePage http://hub.point-blank-international.com

#Neuer Tab / neues Fenster zeigt Homepage
/usr/bin/defaults write com.apple.Safari NewTabBehavior -int 0
/usr/bin/defaults write com.apple.Safari NewWindowBehavior -int 0

#Favoritenleiste in Safari einblenden
/usr/bin/defaults write com.apple.Safari ShowFavoritesBar-v2 -bool true

# Prevent Safari from opening ‘safe’ files automatically after downloading
/usr/bin/defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

#Terminal Notifier installieren
sudo gem install terminal-notifier

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
# Show Birthdays calendar.
/usr/bin/defaults write com.apple.iCal "display birthdays calendar" -bool true
# Turn on time zone support
/usr/bin/defaults write com.apple.iCal "TimeZone support enabled" -bool true
# Kalenderwochen anzeigen
/usr/bin/defaults write com.apple.iCal "Show Week Numbers" -bool true

# Automatically retrieve CalDAV invitations from Mail.
/usr/bin/defaults write com.apple.mail.plist AddInvitationsToICalAutomatically -bool true

##### Nachrichten
/usr/bin/defaults write com.apple.iChat.plist Unified.EnableGroups -bool No
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages array" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages:0 string '[3] Ballroom $durchwahl'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages:1 string '[4] Greenhouse $durchwahl'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages:2 string '[5] Playroom'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages:3 string 'Feld'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAvailableMessages:4 string 'Homeoffice'" ~/Library/Preferences/com.apple.iChat.plist

/usr/libexec/PlistBuddy -c "Add :CustomAwayMessages array" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAwayMessages:0 string 'Feld'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAwayMessages:1 string 'Mittagspause'" ~/Library/Preferences/com.apple.iChat.plist
/usr/libexec/PlistBuddy -c "Add :CustomAwayMessages:2 string 'IT-Support'" ~/Library/Preferences/com.apple.iChat.plist

/usr/libexec/PlistBuddy -c "Add :menuExtras array" ~/Library/Preferences/com.apple.systemuiserver.plist
/usr/libexec/PlistBuddy -c "Add :menuExtras:0 string '/System/Library/CoreServices/Menu Extras/Bluetooth.menu'" ~/Library/Preferences/com.apple.systemuiserver.plist
/usr/libexec/PlistBuddy -c "Add :menuExtras:0 string '/System/Library/CoreServices/Menu Extras/Volume.menu'" ~/Library/Preferences/com.apple.systemuiserver.plist

#### Mail
/usr/bin/defaults write com.apple.mail AddInvitationsToICalAutomatically -bool true
# If outgoing server is unavailable automatically try sending later.
/usr/bin/defaults write com.apple.mail SuppressDeliveryFailure -int 1
/usr/bin/defaults write com.apple.mail MailSound -string ""

#### Skype Plugin
/usr/bin/defaults write com.ecamm.CallRecorder AUTO_RECORD -bool true
/usr/bin/defaults write com.ecamm.CallRecorder DISCARD_SECONDS -int 5
/usr/bin/defaults write com.ecamm.CallRecorder DISCARD_SHORT_CALLS -bool true
/usr/bin/defaults write com.ecamm.CallRecorder AUDIO_ONLY -bool true
/usr/bin/defaults write com.ecamm.CallRecorder VIDEO_QUALITY2 -int 1

#### Tunnelblick defaults v1.1

# Don't check for IP address changes
/usr/bin/defaults write net.tunnelblick.tunnelblick askedUserIfOKToCheckThatIPAddressDidNotChangeAfterConnection -bool TRUE

# Don't send anonymized user profile
/usr/bin/defaults write net.tunnelblick.tunnelblick SUSendProfileInfo -bool FALSE

# Check for and download updates automatically
/usr/bin/defaults write net.tunnelblick.tunnelblick SUEnableAutomaticChecks -bool TRUE
/usr/bin/defaults write net.tunnelblick.tunnelblick SUAutomaticallyUpdate -bool TRUE
/usr/bin/defaults write net.tunnelblick.tunnelblick updateAutomatically -bool TRUE
/usr/bin/defaults write net.tunnelblick.tunnelblick updateCheckAutomatically -bool TRUE

# Don't submit profile info
/usr/bin/defaults write net.tunnelblick.tunnelblick updateSendProfileInfo -bool FALSE

# Don't show startup splash screen
/usr/bin/defaults write net.tunnelblick.tunnelblick doNotShowSplashScreen -bool TRUE

# Only show window display when connecting
/usr/bin/defaults write net.tunnelblick.tunnelblick connectionWindowDisplayCriteria -string "showWhenConnecting"

# Don't show window display on mouseover
/usr/bin/defaults write net.tunnelblick.tunnelblick doNotShowNotificationWindowOnMouseover -bool TRUE

# Don't show disconnected window display
/usr/bin/defaults write net.tunnelblick.tunnelblick doNotShowDisconnectedNotificationWindows -bool TRUE

# Ignore IP address change warning
/usr/bin/defaults write net.tunnelblick.tunnelblick skipWarningThatIPAddressDidNotChangeAfterConnection -bool TRUE

## Datum in Menüleiste anzeigen
/usr/bin/defaults write com.apple.menuextra.clock DateFormat -string "EEE d. MMM  HH:mm"

## Set the icon size of Dock items to 46 pixels
/usr/bin/defaults write com.apple.dock tilesize -int 46

## Set a default program for a fileytpe, i.e. MP3 and WAV to open in Quicktime
/usr/bin/defaults write com.apple.LaunchServices	LSHandlers -array-add \
	'{LSHandlerContentType = "public.mp3"; LSHandlerRoleAll = "com.apple.quicktimeplayerx";}'
/usr/bin/defaults write com.apple.LaunchServices	LSHandlers -array-add \
	'{LSHandlerContentType = "com.microsoft.waveform-audio"; LSHandlerRoleAll = "com.apple.quicktimeplayerx";}'

## Disable Time Machine's pop-up message whenever an external drive is plugged in
sudo /usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Install latest version of PBI 'Status' script
bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/Status/InstallStatus.sh)

## Change user picture
# 1. Curl PBI user pictures tifs from web source into /Library/User\ Pictures/PBI
#sudo dscl . delete /Users/$USER jpegphoto
#sudo dscl . delete /Users/$USER picture
#sudo dscl . create /Users/$USER picture "/Library/User\ Pictures/PBI/$USER.tif"
#  This forces the system to rebuild the system caches along with the local directory cache.
#sudo kextcache -system-caches

## El Capitan: Change login background picture
# Simply replace /Library/Caches/com.apple.desktop.admin.png

echo "Systemeinstellungen gesetzt."

### Kill affected applications

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "Dock" \
	"Finder" "Mail" "Messages" "Safari" "SystemUIServer" "iCal" "cfprefsd"; do
	killall "${app}" &> /dev/null
done

echo "PBI Defaults wurden installiert. Bitte Mac neustarten!"
echo
logger "PBI Defaults wurden installiert."

osascript -e 'tell app "loginwindow" to «event aevtrrst»'
exit 0
