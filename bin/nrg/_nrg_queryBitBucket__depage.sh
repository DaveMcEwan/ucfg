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
#   _nrg_queryBitBucket__depage.sh <args> | jq -s 'flatten'
#   _nrg_queryBitBucket__depage.sh -f <args>
FLATTEN=

# Take credentials from an environment variable, but may be overridden by
# the -u option.
# E.g: `export BITBUCKET_CREDENTIALS=jdoe:XDc1NTkzYjMyODExOrWcTKpzYujz/b/5cQjezElM6+cI`
# <https://confluence.atlassian.com/enterprise/using-personal-access-tokens-1026032365.html>
# No default.
U="$(echo "${BITBUCKET_CREDENTIALS}" | tr -c -d 'A-Za-z0-9:/+=')"

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
  PAGELIMIT='1000'
else
  PAGELIMIT="$(echo "${BITBUCKET_PAGELIMIT}" | tr -c -d '0-9')"
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
while getopts 'du:b:p:l:f' OPT
do
  case $OPT in
    d)  DEBUGMODE=1;;
    u)  U="$(echo "$OPTARG" | tr -c -d 'A-Za-z0-9:/+=')";;
    b)  BASEURI="$(echo "$OPTARG" | tr -c -d 'A-Za-z:/._-')";;
    p)  N_PARAM="$(echo "$OPTARG" | tr -c -d '0-9')";;
    l)  PAGELIMIT="$(echo "$OPTARG" | tr -c -d '0-9')";;
    f)  FLATTEN=1;;
    ?)  printf "Usage: %s [-d] [-u '<user>:<token>'] [-b <base-URI>] [-p <num-params>] [-l <page-limit>] [-f] <URI> <param1> <param2> ...\n" ${THIS}
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
  URI="${BASEURI}${ARG_URI}?limit=${PAGELIMIT}"
fi

# Append parameters to URI.
shift 1
for i in $(seq 1 ${N_PARAM})
do
  PARAM="$(echo "$1" | tr -c -d 'A-Za-z0-9/=_-')"
  URI="${URI}&${PARAM}"
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

# In normal mode, call jq with these options:
# - `-c/--compact-output`: By default, jq pretty-prints JSON output. Using this
#   option will result in more compact output by instead putting each JSON
#   object on a single line.
#   When piping output into another `jq` process, this saves around 10% user
#   CPU time; see experiment notes at the bottom of this file.
# - `-M/--monochrome-output`: By default, jq outputs colored JSON if writing to
#   a terminal. You can force it to produce color even if writing to a pipe or
#   a file using -C, and disable color with -M.
#   Used here to avoid issues with piping output into text-based tools like
#   `grep`, `sed`, `awk`, etc.
# - `--unbuffered`: Flush the output after each JSON object is printed (useful
#   if you're piping a slow data source into jq and piping jq's output
#   elsewhere).
# In debug mode, call jq without those options so that the output is readable.
JQ='jq'
if [ -z "${DEBUGMODE}" ]
then
  JQ="${JQ} -c -M --unbuffered"
fi

# NOTE: `mktemp` isn't in POSIX, but compatible binaries are distributed with
# most Linux and BSD distributions.
# - <http://man.openbsd.org/mktemp.1>
# - <https://man.freebsd.org/cgi/man.cgi?query=mktemp>
# - <https://www.gnu.org/software/coreutils/manual/html_node/mktemp-invocation.html#mktemp-invocation>
TMP_RX_JSON="$(mktemp /tmp/${THIS}.XXXXXXXXXX)"

# Fetch the first page into a temporary file.
${CURL} -u "${U}" --url "${URI}" \
  --request GET \
  --header 'Accept: application/json' \
  > ${TMP_RX_JSON}

# Read the server's response into variables.
# <https://jqlang.github.io/jq/manual/>
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/read.html>
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/paste.html>
read -r nextPageStart isLastPage << CMD
  $(cat ${TMP_RX_JSON} | ${JQ} '.nextPageStart,.isLastPage' | paste -s -)
CMD

if [ ! -z "${DEBUGMODE}" ]
then
  printf "nextPageStart=%s\n" "${nextPageStart}" >&2
  printf "isLastPage=%s\n" "${isLastPage}" >&2
fi

if [ -z "${FLATTEN}" ]
then
  cat ${TMP_RX_JSON} | ${JQ} '.values'
else
  TMP_TX_JSON="$(mktemp /tmp/${THIS}.XXXXXXXXXX)"
  cat ${TMP_RX_JSON} | ${JQ} '.values' > ${TMP_TX_JSON}
fi

while [ "${isLastPage}" = "false" ]
do
  # Fetch the next page into a temporary file, overwriting previous one.
  ${CURL} -u "${U}" --url "${URI}&start=${nextPageStart}" \
    --request GET \
    --header 'Accept: application/json' \
    > ${TMP_RX_JSON}

  read -r nextPageStart isLastPage << CMD
    $(cat ${TMP_RX_JSON} | ${JQ} '.nextPageStart,.isLastPage' | paste -s -)
CMD

  if [ ! -z "${DEBUGMODE}" ]
  then
    printf "nextPageStart=%s\n" "${nextPageStart}" >&2
    printf "isLastPage=%s\n" "${isLastPage}" >&2
  fi

  if [ -z "${FLATTEN}" ]
  then
    cat ${TMP_RX_JSON} | ${JQ} '.values'
  else
    cat ${TMP_RX_JSON} | ${JQ} '.values' >> ${TMP_TX_JSON}
  fi
done

rm ${TMP_RX_JSON}
if [ ! -z "${FLATTEN}" ]
then
  cat ${TMP_TX_JSON} | ${JQ} -s 'flatten'
  rm ${TMP_TX_JSON}
fi


# Experiment: Does the -c/--compact-output option to `jq` affect performance?
#
# Method:
#   1. Make two copies of this script; one with and one without the option.
#   2. On two shells in parallel, started within a second or two of each other:
#     `time for i in $(seq 1 1000); do ./_nrg_list_repos.sh 'XXX'; done`
#
# Results:
#   Without -c/--compact-output on every call to jq:
#     real    68m4.745s
#     user    22m46.863s
#     sys     5m8.704s
#
#   With -c/--compact-output on every call to jq:
#     real    67m16.861s
#     user    20m34.720s
#     sys     5m7.009s
#
# Analysis:
#     user_with / user_without
#   = 20m34.720 / 22m46.863
#   = 20.58     / 22.78
#   = 0.903
#
#   ->  Just under 10% user time wasted on unnecessary formatting/parsing when
#       calling jq without -c/--compact-option.
#
# Critique 1: Only a single datapoint for each variant.
# Rebuttal 1.1: Experiment repeated multiple times with similar results, e.g.
#   10 runs instead of 1000 -> 12.385 / 13.666 = 0.906.
#
# Critique 2: User time may be subject to whatever other processes are running.
# Rebuttal 2.1: The length of real, i.e. wall-clock time, of over 1 hour should
#   capture a representative average result.
# Rebuttal 2.2: Experiment repeated multiple times with similar results.
#
# Notes:
# - Difficult to get listed on `top`, which is a good thing because it means
#   this script isn't rudely affecting other users on the same machine.
#   Highest observed CPU usage was 6%.
#
# Conclusion:
# Use the -c/--compact-output option unless DEBUGMODE is enabled with -d.


# Experiment: Does the -M/--monochrome-output option to `jq` affect performance?
#
# Method:
#   1. Make two copies of this script; one with and one without the option.
#   2. On two shells in parallel, started within a second or two of each other:
#     `time for i in $(seq 1 1000); do ./_nrg_list_repos.sh 'XXX'; done`
#
# Results:
#   Without -M/--monochrome-output on every call to jq:
#     real    68m23.299s
#     user    20m33.345s
#     sys     5m8.000s
#
#   With -M/--monochrome-output on every call to jq:
#     real    68m20.764s
#     user    20m35.089s
#     sys     5m6.438s
#
# Analysis:
#     user_with / user_without
#   = 20m35.089s / 20m33.345s
#   = 1.0014
#
#   ->  No statistical difference.
#
# Notes:
# - The only benefit of monochrome output is that the reader doesn't *need* to
#   filter out ANSI control sequences (but a sanitizing reader still should).
# - Although not a performance enhancement when used with `_nrg_list_repos.sh`,
#   avoiding ANSI control sequences simplifies use of this script with other
#   utilities such as `sed` and `grep`.
#
# Conclusion:
# Use the -M/--monochrome-output option unless DEBUGMODE is enabled with -d.

