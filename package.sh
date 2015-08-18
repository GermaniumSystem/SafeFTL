#!/bin/bash

##This is just a quick little utility script to package the mod with a nice filename, no temp files, etc.


##Set a nice timestamp
DATE="$(date +%Y_%m_%d_%R)"

##Remove all gedit temp files
echo "Removing temporary files..."
find . -name "*~" -type f -delete

##We're going to need a packages directory later, so we should make sure it exists.
[ -d packages ] || mkdir packages

function readMods {
  printf "Would you like to include patches for modded lights? [y/N]: "
  read MODSOPT
  echo ''
}

readMods
if [ "$MODSOPT" != "Y" ] && [ "$MODSOPT" != "y" ] && [ "$MODSOPT" != "N" ] && [ "$MODSOPT" != "n" ] && [ ! -z "$MODSOPT" ] ; then
  echo "I'm not sure how, but you managed to enter something other than a Y or a N."
  readMods
fi

##Temporarily copy the mods directory so clients can identify it after unziping and so we have the option of removing modded patch files.
echo "Copying files..."
cp -r mods "SafeFTL $DATE"

if [ "$MODSOPT" = "Y" ] || [ "$MODSOPT" = "y" ] ; then
  echo "Keeping patch files for modded lights."
else
  echo "Removing patch files for modded lights..."
  rm -r "SafeFTL $DATE/SafeFTL-lights_modded"
fi

GAMEVERPERSIST="$(tail -n 10 "${0##*/}" | grep '#GAMEVERPersist: ' | sed 's/#GAMEVERPersist: //')"
printf -- "Please enter the target game version: [$GAMEVERPERSIST] "
read GAMEVER
if [ -z "$GAMEVER" ] ; then
  GAMEVER="$GAMEVERPERSIST"
else
  sed -i "s/^#GAMEVERPersist: .*/#GAMEVERPersist: ${GAMEVER}/" "${0##*/}"
fi

echo "Checking for file changes..."
SAFEFTLTOTAL="$(du -bs "SafeFTL $DATE/SafeFTL/" | awk '{print $1}')"
SAFEFTLTOTALPERSIST="$(tail -n 10 "${0##*/}" | grep '#SAFEFTLTOTALPersist: ' | sed 's/#SAFEFTLTOTALPersist: //')"
SAFEFTLLIGHTSTOTAL="$(du -bs "SafeFTL $DATE/SafeFTL-lights/" | awk '{print $1}')"
SAFEFTLLIGHTSTOTALPERSIST="$(tail -n 10 "${0##*/}" | grep '#SAFEFTLLIGHTSTOTALPersist: ' | sed 's/#SAFEFTLLIGHTSTOTALPersist: //')"
if [ "$MODSOPT" = "Y" ] || [ "$MODSOPT" = "y" ] ; then
  SAFEFTLMODDEDTOTAL="$(du -bs "SafeFTL $DATE/SafeFTL-lights_modded/" | awk '{print $1}')"
  SAFEFTLMODDEDTOTALPERSIST="$(tail -n 10 "${0##*/}" | grep '#SAFEFTLMODDEDTOTALPersist: ' | sed 's/#SAFEFTLMODDEDTOTALPersist: //')"
fi

SAFEFTLVERPERSIST="$(tail -n 10 "${0##*/}" | grep '#SAFEFTLVERPersist: ' | sed 's/#SAFEFTLVERPersist: //')"
SAFEFTLLIGHTSVERPERSIST="$(tail -n 10 "${0##*/}" | grep '#SAFEFTLLIGHTSVERPersist: ' | sed 's/#SAFEFTLLIGHTSVERPersist: //')"
SAFEFTLMODDEDVERPERSIST="$(tail -n 10 "${0##*/}" | grep '#SAFEFTLMODDEDVERPersist: ' | sed 's/#SAFEFTLMODDEDVERPersist: //')"

if [[ "$SAFEFTLTOTAL" != "$SAFEFTLTOTALPERSIST" ]] ; then
  sed -i "s/^#SAFEFTLTOTALPersist: .*/#SAFEFTLTOTALPersist: ${SAFEFTLTOTAL}/" "${0##*/}"
  printf -- "SafeFTL appears to have been modified. Please specify a version: [$SAFEFTLVERPERSIST] "
  read SAFEFTLVER
  if [ -z "$SAFEFTLVER" ] ; then
    SAFEFTLVER="$SAFEFTLVERPERSIST"
  else
    sed -i "s/^#SAFEFTLVERPersist: .*/#SAFEFTLVERPersist: ${SAFEFTLVER}/" "${0##*/}"
  fi
else
  echo "No changes detected in SafeFTL. Using previous version '$SAFEFTLVERPERSIST'"
  SAFEFTLVER="$SAFEFTLVERPERSIST"
fi
if [[ "$SAFEFTLLIGHTSTOTAL" != "$SAFEFTLLIGHTSTOTALPERSIST" ]] ; then
  sed -i "s/^#SAFEFTLLIGHTSTOTALPersist: .*/#SAFEFTLLIGHTSTOTALPersist: ${SAFEFTLLIGHTSTOTAL}/" "${0##*/}"
  printf -- "SafeFTL-lights appears to have been modified. Please specify a version: [$SAFEFTLLIGHTSVERPERSIST] "
  read SAFEFTLLIGHTSVER
  if [ -z "$SAFEFTLLIGHTSVER" ] ; then
    SAFEFTLLIGHTSVER="$SAFEFTLLIGHTSVERPERSIST"
  else
    sed -i "s/^#SAFEFTLLIGHTSVERPersist: .*/#SAFEFTLLIGHTSVERPersist: ${SAFEFTLLIGHTSVER}/" "${0##*/}"
  fi
else
  echo "No changes detected in SafeFTL-lights. Using previous version '$SAFEFTLLIGHTSVERPERSIST'"
  SAFEFTLLIGHTSVER="$SAFEFTLLIGHTSVERPERSIST"
fi
if [ "$MODSOPT" = "Y" ] || [ "$MODSOPT" = "y" ] ; then
  if [[ "$SAFEFTLMODDEDTOTAL" != "$SAFEFTLMODDEDTOTALPERSIST" ]] ; then
    sed -i "s/^#SAFEFTLMODDEDTOTALPersist: .*/#SAFEFTLMODDEDTOTALPersist: ${SAFEFTLMODDEDTOTAL}/" "${0##*/}"
    printf -- "SafeFTL-lights_modded appears to have been modified. Please specify a version: [$SAFEFTLMODDEDVERPERSIST] "
    read SAFEFTLMODDEDVER
    if [ -z "$SAFEFTLMODDEDVER" ] ; then
      SAFEFTLMODDEDVER="$SAFEFTLMODDEDVERPERSIST"
    else
      sed -i "s/^#SAFEFTLMODDEDVERPersist: .*/#SAFEFTLMODDEDVERPersist: ${SAFEFTLMODDEDVER}/" "${0##*/}"
    fi
  else
    echo "No changes detected in SafeFTL-lights_modded. Using previous version '$SAFEFTLMODDEDVERPERSIST'"
    SAFEFTLMODDEDVER="$SAFEFTLMODDEDVERPERSIST"
  fi
fi


function safeFTLModInfo {
  echo '{' > "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo '	"name" : "SafeFTL",' >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo "	\"version\" : \"${GAMEVER}\"," >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo '	"path" : ".",' >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo '	"dependencies" : [ ],' >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo '	"metadata" : {' >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo '		"author" : "Geo",' >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo '		"description" : "Less intense FTL jumps and teleportation!",' >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo "		\"version\" : \"${SAFEFTLVER}\"" >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo '	}' >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
  echo '}' >> "SafeFTL ${DATE}/SafeFTL/SafeFTL.modinfo"
}

function safeFTLLightsModInfo {
  echo '{' > "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo '	"name" : "SafeFTL-lights",' >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo "	\"version\" : \"${GAMEVER}\"," >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo '	"path" : ".",' >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo '	"dependencies" : [ ],' >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo '	"metadata" : {' >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo '	"author" : "Geo",' >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo '		"description" : "No more light flicker!",' >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo "		\"version\" : \"${SAFEFTLLIGHTSVER}\"" >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo '	}' >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
  echo '}' >> "SafeFTL ${DATE}/SafeFTL-lights/SafeFTL-lights.modinfo"
}

function safeFTLModdedModInfo {
  echo '{' > "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo '	"name" : "SafeFTL-lights_modded",' >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo "	\"version\" : \"${GAMEVER}\"," >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo '	"path" : ".",' >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo '	"dependencies" : ["SafeFTL-lights"],' >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo '	"metadata" : {' >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo '		"author" : "Geo",' >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo '		"description" : "No more light flicker!",' >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo "		\"version\" : \"${SAFEFTLMODDEDVER}\"" >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo '	}' >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
  echo '}' >> "SafeFTL ${DATE}/SafeFTL-lights_modded/SafeFTL-lights_modded.modinfo"
}

echo "Generating .modinfo files..."
safeFTLModInfo
safeFTLLightsModInfo
if [ "$MODSOPT" = "Y" ] || [ "$MODSOPT" = "y" ] ; then
  safeFTLModdedModInfo
fi

##Zip it up.
echo "Compressing files..."
zip -qr "packages/SafeFTL $DATE" "SafeFTL $DATE"
##Remove the temporarary copy.
echo "Cleaning up..."
rm -r "SafeFTL $DATE"

echo "Finished packaging 'SafeFTL $DATE'"



#IMPORTANT: Do not add anything below this line! These comments are used to store values!
#GAMEVERPersist: Pleased Giraffe
#SAFEFTLTOTALPersist: 18430
#SAFEFTLLIGHTSTOTALPersist: 736748
#SAFEFTLMODDEDTOTALPersist: 0
#SAFEFTLVERPersist: 1.4
#SAFEFTLLIGHTSVERPersist: 1.5
#SAFEFTLMODDEDVERPersist: 0
