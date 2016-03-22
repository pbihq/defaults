#!/bin/bash
#
###############################################################################
# Signature Updater
###############################################################################
# Prerequisites: Apple Mail Signature with name "PBI", assigned to PBI Mailadress
# Works only with El Capitan!
###############################################################################
# Declare functions
###############################################################################

# In the AccountsMaps.plist is a line like <string>imap://name.surname@berlin.point-blank-international.com/</string>. Find the line.
Mitarbeiterfile=~/Library/Mail/V3/MailData/Signatures/AccountsMap.plist
Suchlinie=berlin.point-blank-international.com
Maillinie=$(grep "$Suchlinie" $Mitarbeiterfile)

# Now extract only the name from this line. Sed takes the part starting with imap and ends with @. Then, in a second step, it deletes "imap://"
MAName=$(echo $Maillinie | sed -e 's/^.*\(imap[^@]*\).*/\1/' -e 's/imap\:\/\///')

# In this file is a line <string>PBI</string>. Find it. But since the output will be something like "9: <string>PBI</string>", delete everything behind the line number (starting with ":")
Signaturfile=~/Library/Mail/V3/MailData/Signatures/AllSignatures.plist
SignaturzeileTMP=$(grep -n 'PBI' $Signaturfile | cut -d":" -f1)

# But since the line we want is two lines below, get that line instead.
Signaturzeile=$(($SignaturzeileTMP+1))
SignaturzeileEnde=$(($SignaturzeileTMP+3))

# And delete all the lines below
SignaturIDTemp=$(sed -e '1,'"$Signaturzeile"'d' -e "$SignaturzeileEnde"',1000d' < $Signaturfile)

# Now get rid of the code around it.
SignaturID=$(echo $SignaturIDTemp | sed -e 's/<string>//' -e 's/<\/string>//')

# Declare all the paths needed
Source="https://cdn.pbi.online/signature/applemail/$MAName.mailsignature"
Destination=~/Library/Mail/V3/MailData/Signatures
DestinationTemp=~/Library/Mail/V3/MailData

# Declare all the files needed
TempFile=$(echo "$DestinationTemp/$SignaturID.mailsignature")
DestinationFile=$(echo "$Destination/$SignaturID.mailsignature")
NameChange=$(echo "$DestinationTemp/$MAName.mailsignature")

# A little check if the necessary folders exist. If not, abort
if [ -d ~/Library/Mail/V3/MailData/Signatures ]; then
	cd ~/Library/Mail/V3/MailData/Signatures
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
	echo "Die benötigten Ordner wurden nicht gefunden. Bitte informiere die PBI IT. $1" 1>&2
	exit 1
fi

exit 0