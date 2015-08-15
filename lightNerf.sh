#!/bin/bash

#Locates all objects with lighting flicker and creates a patch file to remove said flicker.

SBDIRPERSIST="$(tail -n 2 "${0##*/}" | grep '#SBDIRPersist' | sed 's/#SBDIRPersist: //')"

function readDir {
  printf "Please enter the location of your starbound directory: [${SBDIRPERSIST}] "
  read SBDIR
  echo ''
}
function readMods {
  printf 'Would you like to include modded files? [y/N]: '
  read MODSOPT
  echo ''
}
function readUnpack {
  printf 'Would you like to update packed assets to the latest version (including mod paks)? [Y/n]: '
  read UNPACKOPT
  echo ''
}
function readDebug {
  printf "Would you like to see debug information? [y/N]: "
  read DEBUGOPT
  echo ''
}

readDir
if [ -z "$SBDIR" ] ; then
  SBDIR="$SBDIRPERSIST"
elif [ ! -d "$SBDIR" ] ; then
  echo "Sorry, the directory '$SBDIR' does not seem to exist."
  readDir
elif [ -d "$SBDIR" ] ; then
  sed -i "s,^#SBDIRPersist: .*,#SBDIRPersist: ${SBDIR}," "${0##*/}"
fi
readMods
if [ "$MODSOPT" != "Y" ] && [ "$MODSOPT" != "y" ] && [ "$MODSOPT" != "N" ] && [ "$MODSOPT" != "n" ] && [ ! -z "$MODSOPT" ] ; then
  echo "I'm not sure how, but you managed to enter something other than a Y or a N."
  readMods
fi
readUnpack
if [ "$UNPACKOPT" != "Y" ] && [ "$UNPACKOPT" != "y" ] && [ "$UNPACKOPT" != "N" ] && [ "$UNPACKOPT" != "n" ] && [ ! -z "$UNPACKOPT" ] ; then
  echo "I'm not sure how, but you managed to enter something other than a Y or a N."
  readUnpack
fi
readDebug
if [ "$DEBUGOPT" != "Y" ] && [ "$DEBUGOPT" != "y" ] && [ "$DEBUGOPT" != "N" ] && [ "$DEBUGOPT" != "n" ] && [ ! -z "$DEBUGOPT" ] ; then
  echo "I'm not sure how, but you managed to enter something other than a Y or a N."
  readDebug
fi

if [ "$UNPACKOPT" == "N" ] || [ "$UNPACKOPT" == "n" ] ; then
  echo "Using existing assets."
else
  rm -r ./unpack
  mkdir ./unpack
  if [ "$MODSOPT" == "Y" ] || [ "$MODSOPT" == "y" ] ; then
    mkdir ./unpack/mods
    echo "Searching for mod paks in '$SBDIR/giraffe_storage/mods'"
    find "$SBDIR/giraffe_storage/mods" -type f \( -name "*.modpak" -or -name "*.pak" \) | sed "s,$SBDIR/giraffe_storage/mods/,,g" | while read line ; do
      echo "Unpacking '$SBDIR/giraffe_storage/mods/$line' to './unpack/mods/$(echo $line | sed 's,/, ,g' | awk '{$NF=""; print $0}' | sed 's, ,/,g')'"
      "$SBDIR/linux64/asset_unpacker" "$SBDIR/giraffe_storage/mods/$line" "./unpack/mods/$(echo $line | sed 's,/, ,g' | awk '{$NF=""; print $0}' | sed 's, ,/,g')"
    done
  fi
  echo "Unpacking '$SBDIR/assets/packed.pak' to './unpack/assets/'"
  "$SBDIR/linux64/asset_unpacker" "$SBDIR/assets/packed.pak" ./unpack/assets/
fi

function genPatches {
  echo "$FLICKERLIST" | sed 's/\t/ /g' | sed 's/.object:"/.object: "/g' | while read line ; do
    if [ "$DEBUGOPT" == "Y" ] || [ "$DEBUGOPT" == "y" ] ; then
      echo "$line"
    fi
    #currentFile="$(echo "$line" | awk '{ print $1 }' | sed "s,.*/objects/,objects/," | sed 's/.\{1\}$//')"
    currentFile="$(echo "$line" | sed 's/\.object:.*/\.object/g' | sed 's,.*/objects/,objects/,')"
    if [ ! -f "${SECTION}/$currentFile.patch" ] ; then
      mkdir -p -- "${SECTION}/$currentFile" #&& echo 'mkdir OK' || echo 'mkdir FAIL'
      rm -r -- "${SECTION}/$currentFile" #&& echo 'rm OK' || echo 'rm FAIL'
      echo '[' > "${SECTION}/$currentFile.patch"
    fi
    if echo "$line" | grep -qi '"flickerPeriod"' ; then
      if grep -qi '"op"' "${SECTION}/$currentFile.patch" ; then
        echo ',' >> "${SECTION}/$currentFile.patch"
      fi
      printf '{"op":"remove","path":"/flickerPeriod"}' >> "${SECTION}/$currentFile.patch" #&& echo 'Op1 OK' || echo 'Op1 FAIL'
    fi
    if echo "$line" | grep -qi '"flickerMinIntensity"' ; then
      if grep -qi '"op"' "${SECTION}/$currentFile.patch" ; then
        echo ',' >> "${SECTION}/$currentFile.patch"
      fi
      printf '{"op":"remove","path":"/flickerMinIntensity"}' >> "${SECTION}/$currentFile.patch" #&& echo 'Op2 OK' || echo 'Op2 FAIL'
    fi
    if echo "$line" | grep -qi '"flickerMaxIntensity"' ; then
      if grep -qi '"op"' "${SECTION}/$currentFile.patch" ; then
        echo ',' >> "${SECTION}/$currentFile.patch"
      fi
      printf '{"op":"remove","path":"/flickerMaxIntensity"}' >> "${SECTION}/$currentFile.patch" #&& echo 'Op3 OK' || echo 'Op3 FAIL'
    fi
    if echo "$line" | grep -qi '"flickerPeriodVariance"' ; then
      if grep -qi '"op"' "${SECTION}/$currentFile.patch" ; then
        echo ',' >> "${SECTION}/$currentFile.patch"
      fi
      printf '{"op":"remove","path":"/flickerPeriodVariance"}' >> "${SECTION}/$currentFile.patch" #&& echo 'Op4 OK' || echo 'Op4 FAIL'
    fi
    if echo "$line" | grep -qi '"flickerIntensityVariance"' ; then
      if grep -qi '"op"' "${SECTION}/$currentFile.patch" ; then
        echo ',' >> "${SECTION}/$currentFile.patch"
      fi
      printf '{"op":"remove","path":"/flickerIntensityVariance"}' >> "${SECTION}/$currentFile.patch" #&& echo 'Op5 OK' || echo 'Op5 FAIL'
    fi
    if echo "$line" | grep -qi '"flickerDistance"' ; then
      if grep -qi '"op"' "${SECTION}/$currentFile.patch" ; then
        echo ',' >> "${SECTION}/$currentFile.patch"
      fi
      printf '{"op":"remove","path":"/flickerDistance"}' >> "${SECTION}/$currentFile.patch" #&& echo 'Op6 OK' || echo 'Op6 FAIL'
    fi
    if echo "$line" | grep -qi '"flickerStrength"' ; then
      if grep -qi '"op"' "${SECTION}/$currentFile.patch" ; then
        echo ',' >> "${SECTION}/$currentFile.patch"
      fi
      printf '{"op":"remove","path":"/flickerStrength"}' >> "${SECTION}/$currentFile.patch" #&& echo 'Op7 OK' || echo 'Op7 FAIL'
    fi
    if echo "$line" | grep -qi '"flickerTiming"' ; then
      if grep -qi '"op"' "${SECTION}/$currentFile".patch ; then
        echo ',' >> "${SECTION}/$currentFile.patch"
      fi
      printf '{"op":"remove","path":"/flickerTiming"}' >> "${SECTION}/$currentFile.patch" #&& echo 'Op8 OK' || echo 'Op8 FAIL'
    fi
  done

  find "${SECTION}" -type f | grep '.patch' | while read line ; do
    echo '' >> "$line"
    echo ']' >> "$line"
  done
}

rm -r mods/SafeFTL-lights/
mkdir mods/SafeFTL-lights/
echo "Searching for files to patch in vanilla assets..."
FLICKERLIST="$(grep -r --include \*.object '"flicker' "./unpack/assets/objects" | grep -v 'fluorescentlight' | sort -u)"
SECTION="./mods/SafeFTL-lights"
echo "Patching..."
genPatches

if [ "$MODSOPT" == "Y" ] || [ "$MODSOPT" == "y" ] ; then
  rm -r mods/SafeFTL-lights_modded/
  mkdir mods/SafeFTL-lights_modded/
  SECTION="./mods/SafeFTL-lights_modded"
  echo "Searching for files to patch in unpacked mods..."
  FLICKERLIST="$(grep -r --include \*.object '"flicker' "./unpack/mods" | grep -v 'fluorescentlight' | sort -u)"
  echo "Patching..."
  genPatches
  echo "Searching for files to patch in mods..."
  FLICKERLIST="$(grep -r --include \*.object '"flicker' "${SBDIR}/giraffe_storage/mods" | grep -v 'fluorescentlight' | sort -u)"
  echo "Patching..."
  genPatches
fi


#IMPORTANT: The commented out SBDIRPersist must be at the end of the file! It's actually used by the script!
#This feels incredibly cheaty and like a terrible idea, but it works and allows persistant values.
#SBDIRPersist: /media/Internal-1TB/LinDATA/Steam/SteamApps/common/Starbound.nightly
