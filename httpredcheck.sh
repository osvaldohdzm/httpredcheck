#!/bin/bash

CONNECTION_TIMEOUT=5

redirect_check () {
    echo "Checking all types of redirects for $1"
    echo "Checking redirect for http://$1"
    echo "----"
    curl -ILs "http://$1" | grep -Pi "^HTTP+|Location|X-CDN|Connection"
    echo "--------------------------------------------------------------"
    echo "Checking redirect for http://www.$1"
    echo "----"
    curl -ILs "http://www.$1" | grep -Pi "^HTTP+|Location|X-CDN|Connection"
    echo "--------------------------------------------------------------"
    echo "Checking redirect for https://$1"
    echo "----"
    curl -ILs "https://$1" | grep -Pi "^HTTP+|Location|X-CDN|Connection"
    echo "--------------------------------------------------------------"
    echo "Checking redirect for https://www.$1"
    echo "----"
    curl -ILs "https://www.$1" | grep -Pi "^HTTP+|Location|X-CDN|Connection"
    echo "--------------------------------------------------------------"
}

redirect_check_file () {
dt=$(date '+%d-%m-%Y-%H-%M-%S');
OUTPUT_FILENAME="no-redirected-$dt.txt"
while read p; do
    echo "Checking redirect for http://$p"
    echo "----"
    curl --connect-timeout "$CONNECTION_TIMEOUT"  -ILs "http://$p" | if [ "$( grep -cE 'HTTP/1.0 200|HTTP/1.1 200|HTTP/2 200|HTTP/1.0 403|HTTP/1.1 403|HTTP/2 403' )" -ge 1 ] &&  [ ! "$( grep -cE 'HTTP/1.1 301 Moved|HTTP/1.1 302 Moved|HTTP/1.1 307 Temporary Redirect|HTTP/2 301 Moved|HTTP/2 302 Moved|HTTP/2 307 Temporary Redirect' )" -ge 1 ] ; then echo "http://$p" >> "$OUTPUT_FILENAME"; fi
    echo "--------------------------------------------------------------"
done <"$1"
}



check_file () {
if [ ! -f $1 ]; then
    echo "File not found!"
    exit 2
fi


}
help()
{
    echo "Usage: httpredcheck.sh [ -f | --file ] 
               [ -u | --url ]
               [ -h | --help  ]"
    exit 2
}

SHORT=f:,u:,h
LONG=file:,url:,help
OPTS=$(getopt -a -n httpredcheck --options $SHORT --longoptions $LONG -- "$@")

VALID_ARGUMENTS=$# # Returns the count of arguments that are in short or long options

if [ "$VALID_ARGUMENTS" -eq 0 ]; then
  help
fi

eval set -- "$OPTS"

while :
do
  case "$1" in
    -f | --file )
      my_file="$2"
      shift 1
      ;;
    -u | --url )
      my_url="$2"
      shift 1
      ;;
    -h | --help)
      help
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Unexpected option: $1"
      help
      ;;
  esac
  shift
done

echo "------------------------HTTP Redirect Checker---------------------"
if [ "$my_file" ]
then
    check_file $my_file
    redirect_check_file $my_file
elif [ "$my_url" ]
then
    redirect_check $my_url 
else
    echo "Unexpected option parameter !"
fi    
#redirect_check "$var"





