#!/bin/bash
#
# PBI Mail Signature Generator
#

####################
# Current Banner
####################

linkurl="http://bit.ly/1PVVjQn"
linktitle="We're dispelling three popular myths in Planung &amp; Analyse (German article)"
imageurl="http://cdn.pbi.online/signature/150827_PA_ResearchDesign.png"

banner="$(echo "<a href=\"$linkurl\" title=\"$linktitle\"><img src=\"$imageurl\" alt=\"Banner\" style=\"width:210px;height:auto;max-width:71%;border:0;outline:none;text-decoration:none;\"></a>")"

##################
# Get User Input
##################

clear
echo "PBI SignatureGenerator starten..."
echo
read -p "(Dr.) Vor- und Nachname des Mitarbeiters: " name
echo
read -p "Username (Mailadresse ohne @point-blank-international.com): " username
echo
read -p "Job-Titel des Mitarbeiters? [kein Job-Titel]: " jobtitel
	if [[ -z "$jobtitel" ]]; then
		titelsignature=""
	else
		titelsignature=$(echo "$jobtitel<br>")
	fi
echo
read -p "Twitter-Handle des Mitarbeiters (ohne @) [kein Twitter]: " twitterhandle
	if [[ -z "$twitterhandle" ]]; then
		twittersignatur=""
	else
		twittersignatur=$(echo "<span style=\"width: 16%; display: block; float: left;\">Twitter:</span><a href=\"https://twitter.com/$twitterhandle\" title=\"Follow me on Twitter!\" style=\"text-decoration: none; color: #737577\">@$twitterhandle</a><br><br>")
	fi
echo
read -p "Durchwahl [10]: " durchwahl
	if [[ -z "$durchwahl" ]]; then
		durchwahl="10"
	fi
echo

######################
# Generate Template
######################

cat > ~/Desktop/$username.mailsignature << EOF
Content-Type: text/html;

<head><meta name = "format-detection" content = "telephone=no"></head>
<body style="margin: 0.0px 0.0px 0.0px 0.0px; max-width: 300px">

	<div style="height:30px;"></div>

<a href="http://www.point-blank-international.com/" title="Have a look at our website!"><img src="http://cdn.pbi.online/signature/logo.png" alt="Logo" style="width:auto;height:auto;max-width:156px;border:0;outline:none;text-decoration:none;"></a>

	<div style="height:6px;"></div>

<a href="https://www.google.com/maps/place/Point-Blank+International+Marketing+Research+%26+Consultancy+GmbH/@52.5248698,13.4052438,17z/data=!3m1!4b1!4m2!3m1!1s0x47a851e1c38ab3f1:0x51c4b22a3809297b" title="Come and visit us!" style="text-decoration:none;">
	<div style="max-width:300px;line-height: 1.2em; font-size: 11.0px; font-family: Helvetica, Arial, sans-serif; color: #6eab24;">
	<span style="letter-spacing:0.09em;">Point-Blank International</span><br>
	<span style="letter-spacing:0.00em;">Marketing Research &amp; Consultancy GmbH</span><br></div>

	<div style="max-width: 300px; line-height: 1.5em; font-size: 11.0px; font-family: Helvetica, Arial, sans-serif; color: #737577;">M&uuml;nzstr. 18<span style="font-size: 9.0px;"> &bull; </span>10178 Berlin<span style="font-size: 9.0px;"> &bull; </span>Germany</div></a>

<a href="mailto:$username@point-blank-international.com" title="Send me an e-mail!" style="text-decoration:none; color: #737577"><div style="max-width: 220px; line-height: 1.2em; font-size: 11.0px; font-family: Helvetica, Arial, sans-serif; color: #6eab24;"><br>$name</div>

	<div style="max-width: 300px; line-height: 1.2em; font-size: 11.0px; font-family: Helvetica, Arial, sans-serif; color: #737577;">
	$titelsignature</a><br></div>
	<div style="max-width: 300px; line-height: 1.2em; font-size: 11.0px; font-family: Helvetica, Arial, sans-serif; color: #737577;">
	<span style="width: 16%; display: block; float: left;">Phone:</span><a href="tel:+49-30-3474720-$durchwahl" style="text-decoration:none; color: #737577">+49 30 - 34 74 720 - $durchwahl</a><br>
	<span style="width: 16%; display: block; float: left;">Fax:</span><a href="tel:+49-30-3474720-26" style="text-decoration:none; color: #737577">+49 30 - 34 74 720 - 26</a><br><br>
	$twittersignatur
	</div>

<a href="http://www.point-blank-international.com/" title="Have a look at our website!" style="text-decoration:none;">
<div style="max-width: 300px; line-height: 1.2em; font-size: 11.0px; font-family: Helvetica, Arial, sans-serif; color: #737577;">www.point-blank-international.com<br><br></div></a>

<div style="max-width: 350px; line-height: 1.2em; font-size: 11.0px; font-family: Helvetica, Arial, sans-serif; color: #737577;">Gesch&auml;ftsf&uuml;hrer &#124; Managing Directors:<br>
Dr. Barbara Lang, Dr. Gerhard Keim, Tobias Wenker<br>
Handelsregister &#124; Register of commerce:<br>
Amtsgericht Charlottenburg, HRB 96988 B<br>
Steuernummer &#124; Tax number: 37/487/20760<br>
USt-IdNr. &#124; VAT: DE 814395633</div><br>

$banner
</body>
EOF

###############################################
# Replace special characters with ASCII codes
###############################################

sed -i "" "s/ß/\&szlig;/" ~/Desktop/$username.mailsignature
sed -i "" "s/ \& / \&amp; /" ~/Desktop/$username.mailsignature
sed -i "" "s/ä/\&auml;/" ~/Desktop/$username.mailsignature
sed -i "" "s/Ä/\&Auml;/" ~/Desktop/$username.mailsignature
sed -i "" "s/ö/\&ouml;/" ~/Desktop/$username.mailsignature
sed -i "" "s/Ö/\&Ouml;/" ~/Desktop/$username.mailsignature
sed -i "" "s/ü/\&uuml;/" ~/Desktop/$username.mailsignature
sed -i "" "s/Ü/\&Uuml;/" ~/Desktop/$username.mailsignature

osascript -e 'display notification "Signatur wurde erstellt und auf dem Desktop abgelegt." with title "PBI SignatureGenerator"'

exit 0