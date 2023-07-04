#!/usr/bin/env sh
# Dave McEwan 2023-07-04

# Use `curl` and `jq` to fetch a stream of JSON objects using BitBucket's REST
# API, which uses paging to limit response size.
#
# Print a stream of objects to STDOUT, e.g:
#     [ /* object 0 */
#       { /* result 0 */ },
#       { /* result 1 */ },
#       { /* result 2 */ }
#     ]
#     [ /* object 1 */
#       { /* result 3 */ },
#       { /* result 4 */ },
#       { /* result 5 */ }
#     ]
#
# Each object is printed to STDOUT as soon as possible, so you don't need to
# wait for the server to return all pages before seeing results.
# The output (of multiple objects) can be flattened into one JSON object with
# the -f option, but the JSON will take longer to be available on STDOUT.
#
# <https://developer.atlassian.com/server/bitbucket/rest/latest>


# Fail on uncaught non-zero exit code.
set -e

# Debug mode prints messages to STDERR.
DEBUGMODE=

# Flatten output to one JSON object.
# This waits until all pages have been retrieved before producing any output.
# These two commands are equivalent:
#   $ BitBucket-depage.sh <args> | jq -s 'flatten'
#   $ BitBucket-depage.sh -f <args>
FLATTEN=

# Take credentials from an environment variable, but may be overridden by
# the -u option.
# E.g: `export BITBUCKET_CREDENTIALS=jdoe:XDc1NTkzYjMyODExOrWcTKpzYujz/b/5cQjezElM6+cI`
# No default.
U="${BITBUCKET_CREDENTIALS}"

# Take the `limit` parameter from an environment variable, but may be
# overridden by the -l option.
# Asks the server for how this many items in each page, but the server may give
# fewer.
# E.g: `export BITBUCKET_PAGELIMIT=123`
# Default to 1000, as suggested in BitBucket documentation.
# Without specifying `limit`, BitBucket assumes 25 which is very slow for URIs
# that return long lists.
if [ -z "${BITBUCKET_PAGELIMIT}" ]
then
  PAGELIMIT="1000"
else
  PAGELIMIT="${BITBUCKET_PAGELIMIT}"
fi

# Take the base URI from an environment variable, but may be overridden by the
# -b option.
# The full URI is formed by concatenating $BASEURI to the first positional
# argument.
# E.g: `export BITBUCKET_BASEURI=https://bitbucket.example.com/rest/api/latest/`
# Default to Nordic's server.
# To give a whole URI in one argument, instead of splitting off the base, use
# the -b option with an empty string, i.e. `-b ''`.
if [ -z "${BITBUCKET_BASEURI}" ]
then
  BASEURI="https://projecttools.nordicsemi.no/bitbucket/rest/api/latest/"
else
  BASEURI="${BITBUCKET_BASEURI}"
fi

# Get the name of this script, used in several places.
THIS=$(basename "$0")

# Process the command-line arguments.
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/getopts.html>
# First, the optional arguments.
while getopts 'dfu:b:l:' OPT
do
  case $OPT in
    d)  DEBUGMODE=1;;
    f)  FLATTEN=1;;
    u)  U="$OPTARG";;
    l)  PAGELIMIT="$OPTARG";;
    b)  BASEURI="$OPTARG";;
    ?)  printf "Usage: %s [-d] [-f] [-u '<user>:<token>'] [-l <page-limit>] [-b <base-URI>] <URI>\n" ${THIS}
        exit 2;;
  esac
done
# Second, the positional arguments.
shift $(($OPTIND - 1))
URI="${BASEURI}$1?limit=${PAGELIMIT}"

# Fail on encountering an undefined variable.
set -u

if [ ! -z "${DEBUGMODE}" ]
then
  printf "Credentials=%s\n" "${U}" >&2
  printf "URI=%s\n" "${URI}" >&2
fi

# NOTE: `mktemp` isn't in POSIX, but compatible binaries are distributed with
# most Linux and BSD distributions.
# - <http://man.openbsd.org/mktemp.1>
# - <https://man.freebsd.org/cgi/man.cgi?query=mktemp>
# - <https://www.gnu.org/software/coreutils/manual/html_node/mktemp-invocation.html#mktemp-invocation>
TMP_RX_JSON="$(mktemp /tmp/${THIS}.XXXXXXXXXX)"

# Fetch the first page into a temporary file.
curl -u "${U}" --url "${URI}" \
  --request GET \
  --header 'Accept: application/json' \
  > ${TMP_RX_JSON}

# Read the server's response into variables.
# <https://jqlang.github.io/jq/manual/>
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/read.html>
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/paste.html>
read -r nextPageStart isLastPage << CMD
  $(cat ${TMP_RX_JSON} | jq '.nextPageStart,.isLastPage' | paste -s -)
CMD

if [ ! -z "${DEBUGMODE}" ]
then
  printf "nextPageStart=%s\n" "${nextPageStart}" >&2
  printf "isLastPage=%s\n" "${isLastPage}" >&2
fi

if [ -z "${FLATTEN}" ]
then
  cat ${TMP_RX_JSON} | jq '.values'
else
  TMP_TX_JSON="$(mktemp /tmp/${THIS}.XXXXXXXXXX)"
  cat ${TMP_RX_JSON} | jq '.values' > ${TMP_TX_JSON}
fi

while [ "${isLastPage}" = "false" ]
do
  # Fetch the next page into a temporary file, overwriting previous one.
  curl -u "${U}" --url "${URI}&start=${nextPageStart}" \
    --request GET \
    --header 'Accept: application/json' \
    > ${TMP_RX_JSON}

  read -r nextPageStart isLastPage << CMD
    $(cat ${TMP_RX_JSON} | jq '.nextPageStart,.isLastPage' | paste -s -)
CMD

  if [ ! -z "${DEBUGMODE}" ]
  then
    printf "nextPageStart=%s\n" "${nextPageStart}" >&2
    printf "isLastPage=%s\n" "${isLastPage}" >&2
  fi

  if [ -z "${FLATTEN}" ]
  then
    cat ${TMP_RX_JSON} | jq '.values'
  else
    cat ${TMP_RX_JSON} | jq '.values' >> ${TMP_TX_JSON}
  fi
done

rm ${TMP_RX_JSON}
if [ ! -z "${FLATTEN}" ]
then
  cat ${TMP_TX_JSON} | jq -s 'flatten'
  rm ${TMP_TX_JSON}
fi


