#!/bin/sh

# PBI Drucker installieren
lpadmin -E -p "[4]-Greenhouse-Printer" -v "dnssd://UTAX_TA%203005ci._ipps._tcp.local./?uuid=4509a320-00d5-005e-00f3-00251a507946" -P "/private/tmp/4Greenhouse_Printer.ppd" -L [4]\ Greenhouse -o printer-is-shared=false
cupsenable "[4]-Greenhouse-Printer"
cupsaccept "[4]-Greenhouse-Printer"
lpadmin -E -p "[3]-Ballroom-Printer" -v "dnssd://UTAX_TA%20P-4035%20MFP._ipps._tcp.local./?uuid=4509a320-00ff-0037-0031-00251a51537b" -P "/private/tmp/3Ballroom_Printer.ppd" -L [3]\ Ballroom -o printer-is-shared=false
cupsenable "[3]-Ballroom-Printer"
cupsaccept "[3]-Ballroom-Printer"

# Temporäre Druckertreiber löschen
rm -f /private/tmp/4Greenhouse_Printer.ppd
rm -f /private/tmp/3Ballroom_Printer.ppd

exit 0