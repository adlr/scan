#!/bin/bash

set -e

TRUE="0"
FALSE="1"

PAPER_WIDTH="8.5in"
PAPER_HEIGHT="11in"
RESOLUTION="200"
DUPLEX="$TRUE"

COLOR_BW="Black & White"
COLOR_COLOR="24bit Color[Fast]"
SOURCE_SIMPLEX="Automatic Document Feeder(centrally aligned)"
SOURCE_DUPLEX="Automatic Document Feeder(centrally aligned,Duplex)"
SOURCE_FLATBED="Flatbed"

SOURCE="${SOURCE:-${SOURCE_FLATBED}}"
COLOR_MODE="$COLOR_COLOR"

USING_ADF=0

echo "Scan options:"
echo "  Paper Size: $PAPER_WIDTH x $PAPER_HEIGHT"
echo "  Resolution: $RESOLUTION (dpi)"
if [ "$SOURCE" = "$SOURCE_DUPLEX" ]; then
  USING_ADF=1
  echo "  Duplex: yes"
elif [ "$SOURCE" = "$SOURCE_SIMPLEX" ] ; then
  USING_ADF=1
  echo "  Duplex: no"
elif [ "$SOURCE" = "$SOURCE_FLATBED" ] ; then
  echo "  Flatbed"
else
  echo "  UNKNOWN SOURCE!"
fi
echo "  Color mode: $COLOR_MODE"
if [ $USING_ADF = "1" ] ; then
  echo "  ADF Warning: If too many pages loaded, it will use flatbed"
fi
echo "Hit return to continue"
read dummy

scanimage -d 'brother4:net1;dev0' --batch --format=tiff --resolution $RESOLUTION \
	  --mode "$COLOR_MODE"  \
	  --source "$SOURCE" \
	  -x "$PAPER_WIDTH" -y "$PAPER_HEIGHT"
tiffcp $(ls -v out*.tif) joint.tif
convert joint.tif joint.pdf
ocrmypdf -r --rotate-pages-threshold 3 joint.pdf ocr.pdf
rm -f *.tif joint.pdf
