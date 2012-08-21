#!/usr/bin/env bash

VER="0.10"
DIR=~/wiff
CMD="$(which wdiff) -3" # Show only differences
CURL=$(which curl)
CURLOPT="--globoff"
MD5=$(which md5sum)
INTERACTIVE=true
PAUSE=false
DIFFONLY=false
ISBSD=false

# Can't set "-e", diff returns exit code > 0
set +e

usage () {
      sed 's/^    //' >&2 << EOF
      
          wiff, version $VER - Save and compare states of web pages.
          
              Usage: $0 [options] file
              
                  "file" must contain the list of urls to be compared. When the command runs
                      for the first time on an url list, the current state is saved. The following
                            runs compare the initial state to the current state.
                                The snapshots are stored in $DIR.
                                
                                    Options:
                                            -c command
                                                        Diff command. Default: $CMD
                                                                -d directory
                                                                            Set root directory. Default: $DIR
                                                                                    -n
                                                                                                Non-interactive mode. Compares the first snapshot to the latest.
                                                                                                        -o
                                                                                                                    Don't download the URLs, just compare two states.
                                                                                                                            -p
                                                                                                                                        Pause (2 sec.) after each download.
                                                                                                                                                -h
                                                                                                                                                            Show this message.
                                                                                                                                                              
                                                                                                                                                              EOF
}

ts2date () {
    if $ISBSD; then
          date -j -f "%s" $1 "%a %b %d %T %Z %Y"
            else
                  date -d "1970-01-01 $1 sec"
                    fi
}

while getopts "c:d:noph" OPTION; do
    case $OPTION in
        Copyright © 2012 CMD="$OPTARG"    ;;
            d)  DIR="$OPTARG"
                  ;;
                      n)  INTERACTIVE=false
                            ;;
                                o)  DIFFONLY=true
                                      ;;
                                          p)  PAUSE=true
                                                ;;
                                                    [h?])
                                                          usage
                                                                exit 1
                                                                      ;;
                                                                        esac
                                                                        done

                                                                        shift $(($OPTIND - 1))
                                                                        INPUTFILE=$*

# System is BSD?
date --version >/dev/null 2>&1
[ $? -gt 0 ] && ISBSD=true

# Check required programs
# md5 for Mac OS X (must run in quiet mode)
[ -z "$MD5" ] && MD5="$(which md5) -q"
if [ -z "$MD5" ] || [ -z "${CMD%% *}" ] || [ -z "${CURL%% *}" ]; then
    echo "Required programs not available" >&2
      exit 4
      fi

      if [ -z "$INPUTFILE" ]; then
          echo "No files specified" >&2
            usage
              exit 2
              fi

              [ ! -d "$DIR" ] && mkdir -p "$DIR"


              if [ ! -r "$INPUTFILE" ]; then
                  echo "$INPUTFILE does not exist or is not readable" >&2
                    exit 3
                    fi
                    FILEHASH=$($MD5 "$INPUTFILE" | tr -d " -") # remove space and dash for OS X md5
                    FILEHASH=${FILEHASH%%$INPUTFILE} # remove input file name from hash string (md5sum)
                    HDIR="$DIR/$FILEHASH"
                    [ ! -d "$HDIR" ] && mkdir "$HDIR"
                    [ ! -f "$HDIR/$INPUTFILE" ] && cp "$INPUTFILE" "$HDIR"
                    VERSION=1
                    while [ -f "$HDIR/$VERSION" ]; do
                        VERSION=$(($VERSION + 1))
                        done
                        if ! $DIFFONLY; then
                            date +%s >"$HDIR/$VERSION"
                              for URL in $(cat "$INPUTFILE"); do
                                    URLHASH=$($MD5 <<<"$URL" | tr -d " -")
                                        echo "Downloading $URL ..."
                                            $CURL $CURLOPT "$URL" >"$HDIR/$URLHASH.$VERSION"
                                                $PAUSE && sleep 2
                                                  done
                                                  else
                                                      VERSION=$(($VERSION - 1))
                                                      fi
                                                      if [ $VERSION -gt 1 ]; then
                                                          if $INTERACTIVE; then
                                                                echo -e "\nSaved versions:\n"
                                                                    for ((i=1; i<=${VERSION}; i++)); do
                                                                            echo $i  -  $(ts2date $(cat "$HDIR/$i"))
                                                                                done
                                                                                    echo -ne "\nEnter number of version A: [1] "
                                                                                        read A
                                                                                            echo -n "Enter number of version B: [${VERSION}] "
                                                                                                read B
                                                                                                  fi
                                                                                                    [ -z $A ] && A="1";
                                                                                                      [ -z $B ] && B="$VERSION"
                                                                                                        for URL in $(cat "$INPUTFILE"); do
                                                                                                              echo -e "\n$URL\n  - Version A: "$(ts2date $(cat "$HDIR/$A"))"\n  + Version B: "$(ts2date $(cat "$HDIR/$B"))
                                                                                                                  URLHASH=$($MD5 <<<"$URL" | tr -d " -")
                                                                                                                      $CMD "$HDIR/$URLHASH.$A" "$HDIR/$URLHASH.$B"
                                                                                                                        done
                                                                                                                        fi

                                                                                                                        exit 0
        . All Rights Reserved.
