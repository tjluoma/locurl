#!/bin/zsh
#
#	Author:		Timothy J. Luoma
#	Email:		luomat at gmail dot com
#	Date:		2011-12-02
#
#	Purpose: 	locurl.sh: get a Location of an URL using curl
#				
#	URL:		http://f.luo.ma/locurl.sh [temp: http://dl.dropbox.com/u/18414/f.luo.ma/locurl.sh]

# if this script is called /usr/local/bin/locurl.sh then $NAME will be 'locurl.sh'
NAME="$0:t"

if [ "$#" = "0" ]
then
      # if there are no arguments, get the pasteboard contents
      URL=`pbpaste`
else
      # if there are arguments, assume that is an URL
      URL="$@"
fi


# if growlnotify is installed, use it to inform the user that we are working.
# this is useful when the script is triggered via TextExpander
command which -s growlnotify && \
      growlnotify --message "Working on: $URL" -a "Terminal" --sticky --identifier "$NAME" "$NAME"

case "$URL" in	
      *google.com.*)
                        LOCATION=`curl -sL "$URL" | sed "s#'\"></noscript>##g ; s#.*content=\"0;URL='##g"`
      ;;

      *)

      # use curl to get the 'head' of the URL
      # and follow any location headers
      # grab any header which starts with "Location:" (egrep)
      # and then take only the last one (tail)
      # get rid of Windows EOL characters, which can cause problems (tr) 
      # Then delete everything after the word "Location: " [case insensitive] (sed)
      # and anything that comes after a literal '?' (also sed)
      # this is needed because some URLs might have spaces (yes, really, not %20 but actual spaces)
LOCATION=`curl -s -L --head "$URL" |\
            egrep -i "^Location: " |\
                  tail -1          |\
                        tr -d '\r' |\
            sed 's#^[L|l][O|o][C|c][A|a][T|t][I|i][O|o][N|n]: ##g ; s#\?.*##g' `

      ;;

esac

if [ "$LOCATION" = "" ]
then
            # if we didn't find any Location: headers, we don't do anything except inform the user
            MESSAGE="No better URL for $URL"

else
            # if we did find a Location: header, we copy it to the pasteboard
            # and send the location to stdout
            MESSAGE="$LOCATION is now on pasteboard"
            NAME="$NAME: old url $URL"
            echo "$LOCATION"
            echo "$LOCATION" | pbcopy
fi

# if growlnotify is installed, tell the user what we did
command which -s growlnotify && growlnotify --message "$MESSAGE" -a "Terminal" --identifier "$NAME" "$URL"


exit 0
#EOF