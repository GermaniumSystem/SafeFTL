#!/bin/bash

##This is just a quick little utility script to package the mod with a nice filename, no temp files, etc.

PERSISTFILE='SafeFTL.persist'

#Establish all persist values and populate if needed. (Come back and make this more elegant, future me.)
if grep -q '^GAMEVERPersist: ' "$PERSISTFILE" ; then
  GAMEVERPERSIST="$(grep '^GAMEVERPersist' "$PERSISTFILE" | sed 's/^GAMEVERPersist: //')"
else
  echo "GAMEVERPersist: Glad Giraffe" >> "$PERSISTFILE"
  GAMEVERPERSIST="Glad Giraffe"
fi
if grep -q '^SAFEFTLTOTALPersist: ' "$PERSISTFILE" ; then
  SAFEFTLTOTALPERSIST="$(grep '^SAFEFTLTOTALPersist' "$PERSISTFILE" | sed 's/^SAFEFTLTOTALPersist: //')"
else
  echo "SAFEFTLTOTALPersist: 0" >> "$PERSISTFILE"
  SAFEFTLTOTALPERSIST="0"
fi
if grep -q '^SAFEFTLLIGHTSTOTALPersist: ' "$PERSISTFILE" ; then
  SAFEFTLLIGHTSTOTALPERSIST="$(grep '^SAFEFTLLIGHTSTOTALPersist' "$PERSISTFILE" | sed 's/^SAFEFTLLIGHTSTOTALPersist: //')"
else
  echo "SAFEFTLLIGHTSTOTALPersist: 0" >> "$PERSISTFILE"
  SAFEFTLLIGHTSTOTALPERSIST="0"
fi
if grep -q '^SAFEFTLMODDEDTOTALPersist: ' "$PERSISTFILE" ; then
  SAFEFTLMODDEDTOTALPERSIST="$(grep '^SAFEFTLMODDEDTOTALPersist' "$PERSISTFILE" | sed 's/^SAFEFTLMODDEDTOTALPersist: //')"
else
  echo "SAFEFTLMODDEDTOTALPersist: 0" >> "$PERSISTFILE"
  SAFEFTLMODDEDTOTALPERSIST="0"
fi
if grep -q '^SAFEFTLVERPersist: ' "$PERSISTFILE" ; then
  SAFEFTLVERPERSIST="$(grep '^SAFEFTLVERPersist' "$PERSISTFILE" | sed 's/^SAFEFTLVERPersist: //')"
else
  echo "SAFEFTLVERPersist: 0.1" >> "$PERSISTFILE"
  SAFEFTLVERPERSIST="0.1"
fi
if grep -q '^SAFEFTLLIGHTSVERPersist: ' "$PERSISTFILE" ; then
  SAFEFTLLIGHTSVERPERSIST="$(grep '^SAFEFTLLIGHTSVERPersist' "$PERSISTFILE" | sed 's/^SAFEFTLLIGHTSVERPersist: //')"
else
  echo "SAFEFTLLIGHTSVERPersist: 0.1" >> "$PERSISTFILE"
  SAFEFTLLIGHTSVERPERSIST="0.1"
fi
if grep -q '^SAFEFTLMODDEDVERPersist: ' "$PERSISTFILE" ; then
  SAFEFTLMODDEDVERPERSIST="$(grep '^SAFEFTLMODDEDVERPersist' "$PERSISTFILE" | sed 's/^SAFEFTLMODDEDVERPersist: //')"
else
  echo "SAFEFTLMODDEDVERPersist: 0.1" >> "$PERSISTFILE"
  SAFEFTLMODDEDVERPERSIST="0.1"
fi

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

printf -- "Please enter the target game version: [$GAMEVERPERSIST] "
read GAMEVER
if [ -z "$GAMEVER" ] ; then
  GAMEVER="$GAMEVERPERSIST"
else
  sed -i "s/^GAMEVERPersist: .*/GAMEVERPersist: ${GAMEVER}/" "$PERSISTFILE"
fi

echo "Checking for file changes..."
SAFEFTLTOTAL="$(du -bs "SafeFTL $DATE/SafeFTL/" | awk '{print $1}')"
SAFEFTLLIGHTSTOTAL="$(du -bs "SafeFTL $DATE/SafeFTL-lights/" | awk '{print $1}')"
if [ "$MODSOPT" = "Y" ] || [ "$MODSOPT" = "y" ] ; then
  SAFEFTLMODDEDTOTAL="$(du -bs "SafeFTL $DATE/SafeFTL-lights_modded/" | awk '{print $1}')"
fi


if [[ "$SAFEFTLTOTAL" != "$SAFEFTLTOTALPERSIST" ]] ; then
  sed -i "s/^SAFEFTLTOTALPersist: .*/SAFEFTLTOTALPersist: ${SAFEFTLTOTAL}/" "$PERSISTFILE"
  printf -- "SafeFTL appears to have been modified. Please specify a version: [$SAFEFTLVERPERSIST] "
  read SAFEFTLVER
  if [ -z "$SAFEFTLVER" ] ; then
    SAFEFTLVER="$SAFEFTLVERPERSIST"
  else
    sed -i "s/^SAFEFTLVERPersist: .*/SAFEFTLVERPersist: ${SAFEFTLVER}/" "$PERSISTFILE"
  fi
else
  echo "No changes detected in SafeFTL. Using previous version '$SAFEFTLVERPERSIST'"
  SAFEFTLVER="$SAFEFTLVERPERSIST"
fi
if [[ "$SAFEFTLLIGHTSTOTAL" != "$SAFEFTLLIGHTSTOTALPERSIST" ]] ; then
  sed -i "s/^SAFEFTLLIGHTSTOTALPersist: .*/SAFEFTLLIGHTSTOTALPersist: ${SAFEFTLLIGHTSTOTAL}/" "$PERSISTFILE"
  printf -- "SafeFTL-lights appears to have been modified. Please specify a version: [$SAFEFTLLIGHTSVERPERSIST] "
  read SAFEFTLLIGHTSVER
  if [ -z "$SAFEFTLLIGHTSVER" ] ; then
    SAFEFTLLIGHTSVER="$SAFEFTLLIGHTSVERPERSIST"
  else
    sed -i "s/^SAFEFTLLIGHTSVERPersist: .*/SAFEFTLLIGHTSVERPersist: ${SAFEFTLLIGHTSVER}/" "$PERSISTFILE"
  fi
else
  echo "No changes detected in SafeFTL-lights. Using previous version '$SAFEFTLLIGHTSVERPERSIST'"
  SAFEFTLLIGHTSVER="$SAFEFTLLIGHTSVERPERSIST"
fi
if [ "$MODSOPT" = "Y" ] || [ "$MODSOPT" = "y" ] ; then
  if [[ "$SAFEFTLMODDEDTOTAL" != "$SAFEFTLMODDEDTOTALPERSIST" ]] ; then
    sed -i "s/^SAFEFTLMODDEDTOTALPersist: .*/SAFEFTLMODDEDTOTALPersist: ${SAFEFTLMODDEDTOTAL}/" "$PERSISTFILE"
    printf -- "SafeFTL-lights_modded appears to have been modified. Please specify a version: [$SAFEFTLMODDEDVERPERSIST] "
    read SAFEFTLMODDEDVER
    if [ -z "$SAFEFTLMODDEDVER" ] ; then
      SAFEFTLMODDEDVER="$SAFEFTLMODDEDVERPERSIST"
    else
      sed -i "s/^SAFEFTLMODDEDVERPersist: .*/SAFEFTLMODDEDVERPersist: ${SAFEFTLMODDEDVER}/" "$PERSISTFILE"
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
#GAMEVERPersist: Glad Giraffe
#SAFEFTLTOTALPersist: 18435
#SAFEFTLLIGHTSTOTALPersist: 736748
#SAFEFTLMODDEDTOTALPersist: 0
#SAFEFTLVERPersist: 1.5
#SAFEFTLLIGHTSVERPersist: 1.5
#SAFEFTLMODDEDVERPersist: 0
