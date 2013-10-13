#!/bin/bash
# Author: Marko Martinović
# License: GPLv2

# Input directory
MAGEDIR=""

# Output file name
OUTFILE=""

EVENTTAG="Mage::dispatchEvent"

# Exit with message and press any key to exit
function exit_with_pause() {
    echo -e "$1\n"
    read -p "Press any key to EXIT"
    exit 1
}

# Prompts for yes/no confirmation with no being default.
# Returns 1 for no and 0 for yes.
function yes_no_pause() {
    read -p "$1 (y/N)?" choice
    case "$choice" in
    y|Y ) return 0;;
    n|N ) return 1;;
    * ) return 1;;
    esac
}

# Prints usage instructions
function usage() {
  cat << EOF
Usage: $0 OPTIONS

Generates list of events from Magento source code, and saves result to file

OPTIONS:
-h Show this message
-i Magento root directory (required)
-o Output file (optional, "events.txt" inside working directory by default)

Examples:
- For Magento installation with absolute path /var/www/magento/ export to "events.txt" file inside /home/$USER/ directory
$0 -i /var/www/magento/ -o /home/$USER/

EOF
}

# Parse script arguments
while getopts "hi:o:" OPTION
do
case $OPTION in
    h)
      usage
      exit 1
      ;;
    i)
      MAGEDIR=$OPTARG
      ;;
    o)
      OUTFILE=$OPTARG
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

# $MAGEDIR must not be empty
if [ -z $MAGEDIR ]
    then
    usage
    exit 1
fi

# Magento root directory must exist
if [ ! -d $MAGEDIR ]
    then
    exit_with_pause "Input directory \"$MAGEDIR\" isn't valid Magento root directory."
fi

MAGEAPPDIR="$MAGEDIR/app"

# Magento app directory must exist
if [ ! -d $MAGEAPPDIR ]
    then
    exit_with_pause "Input directory \"$MAGEDIR\" isn't valid Magento root directory."
fi

# $OUTFILE must not be empty
if [ -z $OUTFILE ]
    then
    OUTFILE="$MAGEDIR/events.txt"
fi

# Remove previous if exists
if [ -f $OUTFILE ]
    then
    yes_no_pause "Continuing will remove existing \"$OUTFILE\". Shall we proceed?"
    if [ $? = 1 ]
        then
        exit_with_pause "Process aborted."
    fi
    rm $OUTFILE>/dev/null 2>&1
    if [ $? = 1 ]
        then
        exit_with_pause "Couldn't remove existing \"$OUTFILE\" output file. Permissions?"
    fi
fi

touch $OUTFILE >/dev/null 2>&1
# Must be authorized to write into output directory
if [ $? = 1 ]
    then
    exit_with_pause "Couldn't create \"$OUTFILE\" output file. Permissions?"
fi

echo "INPUT: $MAGEDIR"
echo "OUTPUT: $OUTFILE"

# Do it
grep -rin -B2 -A2 $EVENTTAG $MAGEAPPDIR > $OUTFILE

# Count it
COUNT=$(cat $OUTFILE | grep -o $EVENTTAG | wc -l)

echo "COUNT: $COUNT"
echo -e "--\nCOUNT:$COUNT" >> $OUTFILE

# Exit success
exit 0
