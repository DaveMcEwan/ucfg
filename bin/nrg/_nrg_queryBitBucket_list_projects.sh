#!/usr/bin/env sh
# Dave McEwan 2023-07-17

# Use `_nrg_queryBitBucket__depage.sh` list projects available on the remote,
# printed to STDOUT, whose projectKeys match an ERE regex.
# Each line features the projectKey..
#
# Environment variable `$BITBUCKET_CREDENTIALS` must be set.
# E.g: `export BITBUCKET_CREDENTIALS=jdoe:XDc1NTkzYjMyODExOrWcTKpzYujz/b/5cQjezElM6+cI`


# Fail on uncaught non-zero exit code.
set -e

# Debug mode prints messages to STDERR.
DEBUGMODE=

# Ensure that exactly one line is printed.
# Off by default, overridden by the option -1.
EXACTLYONE=

# Get the sanitized name of this script, used to print usage message and as a
# template for temporary filenames.
# To aid debugging, the sanitized name is found by calling this script with an
# invalid option, such as -h.
THIS="$(echo "$(basename "$0")" | tr -c -d 'a-z_.')"

# Process the command-line arguments.
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/getopts.html>
# First, the optional arguments.
while getopts 'd1' OPT
do
  case $OPT in
    d)  DEBUGMODE=1;;
    1)  EXACTLYONE=1;;
    ?)  printf "Usage: %s [-d] [-1] [<ERE>]\n" ${THIS}
        exit 2;;
  esac
done
# Second, the positional arguments.
shift $(($OPTIND - 1))

# Regex applied to slugs, in POSIX Extended Regular Expression syntax.
# Defaults to the least restrictive, `.*`, matching any slug.
# <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html>
# <https://en.wikipedia.org/wiki/Kleene_star>
if [ -z "$1" ]
then
  REKEY_PARTIAL='.*'
else
  REKEY_PARTIAL="$1"
fi

# Fail on encountering an undefined variable.
set -u

# The provided ERE is applied to whole lines outputted by jq.
REKEY="^${REKEY_PARTIAL}\$"

# BitBucket's REST API uses paging.
# NRG_DEPAGE points to a utility which extracts the values into one JSON array,
# i.e. an ordered list of JSON objects.
# <https://www.json.org/json-en.html>
NRG_DEPAGE='_nrg_queryBitBucket__depage.sh'

# Pass the -d option down to `_nrg_queryBitBucket__depage.sh` which uses it in the
# same way.
if [ ! -z "${DEBUGMODE}" ]
then
  NRG_DEPAGE="${NRG_DEPAGE} -d"
fi

# NOTE: The -f option to `_nrg_queryBitBucket__depage.sh` waits until all pages
# are received before returning any output.
# There is no way to set the -f option in this script, so data is processed as
# soon as it is received.

# NOTE: The -u option to `_nrg_queryBitBucket__depage.sh` allows the user to
# pass credentials on the command line.
# There is no way to set the -u option in this script, so credentials must be
# given with the environment variable `$BITBUCKET_CREDENTIALS`.

# NOTE: The -l option to `_nrg_queryBitBucket__depage.sh` specifies how many
# items to request from BitBucket with each URI.
# That may be useful for system administrators looking to tune performance,
# however, this should not be changed under normal circumstances.
# Therefore, there is no way to set the -l option in this script.

# NOTE: The -b option to `_nrg_queryBitBucket__depage.sh` specifies the base URI
# of the BitBucket Git server.
# There is no way to set the -b option in this script, but the environment
# variable `$BITBUCKET_BASEURI` can override the default.
# You may wish to set the `$BITBUCKET_BASEURI` environment variable if, for
# example, Atlassian release an incompatible version of the API, or to
# facilitate an IT systems migration.

# Example of using the `_nrg_queryBitBucket__depage.sh` script manually:
#   BITBUCKET_CREDENTIALS="jdoe:XDc1NTkzYjMyODExOrWcTKpzYujz/b/5cQjezElM6+cI" \
#     _nrg_queryBitBucket__depage.sh projects/SIG-DOGIT/repos > values.json

# <https://developer.atlassian.com/server/bitbucket/rest/v810/api-group-repository/#api-api-latest-repos-get>
URI="projects"
if [ ! -z "${DEBUGMODE}" ]
then
  printf "URI=%s\n" "${URI}" >&2
fi


JQ_QUERY='\(.key | select(contains(" ") | not))'
JQ_QUERY=".[] | \"${JQ_QUERY}\""


if [ ! -z "${DEBUGMODE}" ]
then
  printf "JQ_QUERY=%s\n" "${JQ_QUERY}" >&2
fi


# Use the depager subscript, which puts JSON data on STDOUT as it's received,
# then use `jq` string interpolation to produce one line per repository.
# Those lines are piped into `grep` and filtered using the user-supplied ERE.
# When the -1 option (the number one) is given, the output lines are counted
# using `wc` and exit status is set to non-zero if the number of output lines
# is either zero or more than one.
if [ -z "${EXACTLYONE}" ]
then
  ${NRG_DEPAGE} "${URI}" \
  | jq -r "${JQ_QUERY}" \
  | grep -Ei "${REKEY}"
else
  COUNT=$(${NRG_DEPAGE} ${URI} \
  | jq -r "${JQ_QUERY}" \
  | grep -Ei "${REKEY}" \
  | tee /dev/tty | wc -l)

  if [ "${COUNT}" = '1' ]
  then
    exit 0
  else
    if [ ! -z "${DEBUGMODE}" ]
    then
      printf "COUNT=%s\n" "${COUNT}" >&2
    fi
    exit -1
  fi
fi
