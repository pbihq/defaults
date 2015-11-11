#!/bin/sh

# Scripts starten
bash /private/tmp/PBI-Printer-Setup.sh
bash /private/tmp/Printer-Ballroom-Settings.sh
bash /private/tmp/Printer-Greenhouse-Settings.sh

# Scripts löschen
rm -f /private/tmp/PBI-Printer-Setup.sh
rm -f /private/tmp/Printer-Ballroom-Settings.sh
rm -f /private/tmp/Printer-Greenhouse-Settings.sh

exit 0