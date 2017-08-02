#!/bin/bash

## uncommont following line to debug 
#set -e
#set -x

CURL=curl
OREILLY="http://www.oreilly.com"

## type: type of book
## book_name: name of book that want to download
function get-book() {
    curl -O ${OREILLY}/$1/free/files/$2
}

function usage() {
cat <<EOF
Usage: $(basename $0) <subcommand> [args]
subcommand:
  list <type>
  get  <type> name
    except all type.
  help

args:
  type [all | data | security | design | iot | programming | web-platform | webops]

EOF
}


## type: type of book
function get-book-list() {
    local types=${1:-"data security design iot programming web-platform webops"}
    declare -A BOOKS
    case $1 in
	data|security|design|iot|programming|web-platform|webops)
    	    BOOKS+=([${1}]="$(${CURL} http://www.oreilly.com/${1}/free/ -s | sed -e 's/href="/\n/' -e 's/\.csp/\.csp\n/' | egrep "free/.*\.csp")")
	    ;;
	all)
	    for class in ${CLASSES}
	    do
		BOOKS+=([${class}]="$(${CURL} http://www.oreilly.com/${class}/free/ -s | sed -e 's/href="/\n/' -e 's/\.csp/\.csp\n/' | egrep "free/.*\.csp")")
		echo -n "."
	    done
	    ;;
	*)
	    echo "Invalide type of book."
	    usage
	    exit 0
	    ;;
    esac
    
    for _type  in ${types}
    do
	echo '----------['${_type^^}']----------'
	for book in ${BOOKS[$_type]}
	do
	    book=${book##*/}
	    book=${book%.csp}
	    echo ${book}
	done
    done
}

# start main
while true
do
    case $1 in
	list)
	    shift
	    get-book-list $@
	    exit 0
	    ;;
	get)
	    shift
	    get-book $@
	    exit 0
	    ;;
	help|*)
	    usage
	    exit 1
	    ;;
    esac
done
