#!/usr/bin/env sh
# Dave McEwan 2023-07-04

# Use `curl` to fetch a raw content using BitBucket's REST API.
# Print content directly to STDOUT.


# Fail on uncaught non-zero exit code.
set -e

# Debug mode prints messages to STDERR.
DEBUGMODE=

# Take credentials from an environment variable, but may be overridden by
# the -u option.
# E.g: `export BITBUCKET_CREDENTIALS=jdoe:XDc1NTkzYjMyODExOrWcTKpzYujz/b/5cQjezElM6+cI`
# <https://confluence.atlassian.com/enterprise/using-personal-access-tokens-1026032365.html>
# No default.
U="$(echo "${BITBUCKET_CREDENTIALS}" | tr -c -d 'A-Za-z0-9:/+=')"

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
  BASEURI='https://projecttools.nordicsemi.no/bitbucket/rest/api/latest/'
else
  BASEURI="$(echo "${BITBUCKET_BASEURI}" | tr -c -d 'a-z:/._-')"
fi

# Parent scripts may pass a number of query parameters after the URI.
# For example, in the URI `foo/bar?x=1&y=2`, there are 2 query parameters;
# `x=1` and `y=2`.
# The number of parameters to be included in the full URI must be given with
# the -p option, i.e.:
#   _nrg_queryBitBucket__depage.sh -p 2 foo/bar x=1 y=2
N_PARAM='0'

# Get the sanitized name of this script, used to print usage message and as a
# template for temporary filenames.
# To aid debugging, the sanitized name is found by calling this script with an
# invalid option, such as -h.
THIS="$(echo "$(basename "$0")" | tr -c -d 'a-z_.')"

# Process the command-line arguments.
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/getopts.html>
# First, the optional arguments.
while getopts 'du:b:p:' OPT
do
  case $OPT in
    d)  DEBUGMODE=1;;
    u)  U="$(echo "$OPTARG" | tr -c -d 'A-Za-z0-9:/+=')";;
    b)  BASEURI="$(echo "$OPTARG" | tr -c -d 'A-Za-z:/._-')";;
    p)  N_PARAM="$(echo "$OPTARG" | tr -c -d '0-9')";;
    ?)  printf "Usage: %s [-d] [-u '<user>:<token>'] [-b <base-URI>] [-p <num-params>] <URI> <param1> <param2> ...\n" ${THIS}
        exit 2;;
  esac
done
# Second, the positional arguments.
shift $(($OPTIND - 1))

# Fail on encountering an undefined variable.
set -u

# URI must be provided.
if [ -z "$1" ]
then
  printf "Usage: <URI> must be provided\n" >&2
  exit 1
else
  ARG_URI="$(echo "$1" | tr -c -d 'A-Za-z:/._-')"
  URI="${BASEURI}${ARG_URI}"
fi

# Append parameters to URI.
shift 1
for i in $(seq 1 ${N_PARAM})
do
  if [ $i = '1' ]
  then
    SEP='?'
  else
    SEP='&'
  fi

  PARAM="$(echo "$1" | tr -c -d 'A-Za-z0-9/=_-')"
  URI="${URI}${SEP}${PARAM}"
  shift 1 || break
done

CURL='curl'
if [ -z "${DEBUGMODE}" ]
then
  CURL="${CURL} --silent --show-error"
else
  printf "Credentials=%s\n" "${U}" >&2
  printf "URI=%s\n" "${URI}" >&2
fi

${CURL} -u "${U}" --url "${URI}" \
  --request GET \
  --header 'Accept: application/json'
