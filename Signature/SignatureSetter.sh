#!/bin/bash
#
###############################################################################
# Signature Setter
###############################################################################
# Prerequisites: Apple Mail Signature with name "PBI", assigned to PBI Mailadress
# Compatible with macOS 10.11 and 10.12
###############################################################################
# Declare functions
###############################################################################

# Get installed macOS version
OperatingSystem=$(sw_vers -productVersion)

# Set Mailversion for correct filepath
case $OperatingSystem in
10.11*) Mailversion="V3";;
10.12*) Mailversion="V4";;
10.13*) Mailversion="V5";;
*) echo "Error while setting mail version. Please note: This script only works with macOS 10.11 and 10.12 (and 10.13 as beta)"
esac

# In the AccountsMaps.plist is a line like <string>imap://name.surname@mail.point-blank-international.com/</string>. Find the line.
Mitarbeiterfile=~/Library/Mail/$Mailversion/MailData/Signatures/AccountsMap.plist
Suchlinie=mail.point-blank-international.com
Maillinie=$(grep "$Suchlinie" $Mitarbeiterfile)

# Now extract only the name from this line. Sed takes the part starting with imap and ends with @. Then, in a second step, it deletes "imap://"
MAName=$(echo $Maillinie | sed -e 's/^.*\(imap[^@]*\).*/\1/' -e 's/imap\:\/\///')

# Temporary alternative, if there is still the old Server in the Mail Program.
if [ -z "$MAName" ]; then
SuchlinieAlt=berlin.point-blank-international.com
MaillinieAlt=$(grep "$SuchlinieAlt" $Mitarbeiterfile)

MAName=$(echo $MaillinieAlt | sed -e 's/^.*\(imap[^@]*\).*/\1/' -e 's/imap\:\/\///')
fi

# Send a mail if $MAName is empty
if [ -z "$MAName" ]; then

	echo "tell application \"Mail\"

	set theMessage to make new outgoing message with properties {subject:\"Signaturscript - Fehler\", content:\"Bei einem Mitarbeiter konnte der Name nicht ausgelesen werden.\", visible:false}

	tell theMessage
		make new to recipient with properties {name:\"PBI Logs\", address:\"logs@point-blank-international.com\"}

		##Send the Message
		send

	end tell
end tell
" | osascript
	exit 1
fi

# In this file is a line <string>PBI</string>. Find it. But since the output will be something like "9: <string>PBI</string>", delete everything behind the line number (starting with ":")
Signaturfile=~/Library/Mail/$Mailversion/MailData/Signatures/AllSignatures.plist
SignaturzeileTMP=$(grep -n 'PBI' $Signaturfile | cut -d":" -f1)

# But since the line we want is two lines below, get that line instead.
Signaturzeile=$(($SignaturzeileTMP+1))
SignaturzeileEnde=$(($SignaturzeileTMP+3))

# And delete all the lines below
SignaturIDTemp=$(sed -e '1,'"$Signaturzeile"'d' -e "$SignaturzeileEnde"',1000d' < $Signaturfile)

# Now get rid of the code around it.
SignaturID=$(echo $SignaturIDTemp | sed -e 's/<string>//' -e 's/<\/string>//')

# Send a mail if $SignaturID is empty
if [ -z "$SignaturID" ]; then

	echo "tell application \"Mail\"

	set theMessage to make new outgoing message with properties {subject:\"Signaturscript - Fehler\", content:\"Bei $MAName konnte die Signatur-ID nicht ausgelesen werden.\", visible:false}

	tell theMessage
		make new to recipient with properties {name:\"PBI Logs\", address:\"logs@point-blank-international.com\"}

		##Send the Message
		send

	end tell
end tell
" | osascript
	exit 1
fi

# Declare all the paths needed
Source="https://cdn.pbi.online/signature/applemail/$MAName.mailsignature"
Destination=~/Library/Mail/$Mailversion/MailData/Signatures
DestinationTemp=~/Library/Mail/$Mailversion/MailData

# Declare all the files needed
TempFile=$(echo "$DestinationTemp/$SignaturID.mailsignature")
DestinationFile=$(echo "$Destination/$SignaturID.mailsignature")
NameChange=$(echo "$DestinationTemp/$MAName.mailsignature")

# A little check if the necessary folders exist. If not, abort
if [ -d ~/Library/Mail/$Mailversion/MailData/Signatures ]; then
	cd ~/Library/Mail/$Mailversion/MailData/Signatures
	# Now magic happens. First, unlock the present mail signature.
	chflags nouchg "$DestinationFile"
	# Copy the file from Webspace to a temp folder
	curl -s $Source -o $DestinationTemp/$MAName.mailsignature
	# Change filename to signature filename
	mv -f "$NameChange" "$TempFile"
	# Move file to final destination
	mv -f "$TempFile" "$DestinationFile"
	# Lock the mail signature again.
	chflags uchg "$DestinationFile"
else
	# In case of error give an error message.
	echo "tell application \"Mail\"

	set theMessage to make new outgoing message with properties {subject:\"Signaturscript - Fehler\", content:\"Bei $MAName wurde der Signatures-Ordner nicht gefunden oder die Dateien konnten nicht kopiert werden.\", visible:false}

	tell theMessage
		make new to recipient with properties {name:\"PBI Logs\", address:\"logs@point-blank-international.com\"}

		##Send the Message
		send

	end tell
end tell
" | osascript
	exit 1
fi

exit 0
