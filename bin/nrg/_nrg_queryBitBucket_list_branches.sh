#!/usr/bin/env sh
# Dave McEwan 2023-07-13

# Use `_nrg_queryBitBucket__depage.sh` list the branches of a remote repository
# (identified by its slug), printed to STDOUT, whose branch names match an ERE
# regex.
# Each line features the branch name followed, optionally, by the hash of the
# latest commit, delimited by a tab character.
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

# Take the projectKey (BitBucket terminology) from an environment variable, but
# may be overridden by the -p option.
# E.g: `export BITBUCKET_PROJECTKEY=SAG`
# The environment variable is sanitized to allow only ASCII alpanumericals,
# underscore, and hyphen characters.
# Default to Nordic's SIG-DOGIT.
if [ -z "${BITBUCKET_PROJECTKEY}" ]
then
  PROJECT='SIG-DOGIT'
else
  PROJECT="$(echo "${BITBUCKET_PROJECTKEY}" | tr -c -d 'A-Za-z0-9_-')"
fi

# Show the latest commit hash of each branch.
# Off by default, overridden by the option -c.
SHOW_COMMIT=

# Find tags instead of branches.
# Off by default, overridden by the option -t.
TAG_NOT_BRANCH=

# Get the sanitized name of this script, used to print usage message and as a
# template for temporary filenames.
# To aid debugging, the sanitized name is found by calling this script with an
# invalid option, such as -h.
THIS="$(echo "$(basename "$0")" | tr -c -d 'a-z_.')"

# Process the command-line arguments.
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/getopts.html>
# First, the optional arguments.
while getopts 'd1p:ct' OPT
do
  case $OPT in
    d)  DEBUGMODE=1;;
    1)  EXACTLYONE=1;;
    p)  PROJECT="$(echo "${OPTARG}" | tr -c -d 'A-Za-z0-9_-')";;
    c)  SHOW_COMMIT=1;;
    t)  TAG_NOT_BRANCH=1;;
    ?)  printf "Usage: %s [-d] [-1] [-p <projectKey>] [-c] [-t] <slug> [<ERE>]\n" ${THIS}
        exit 2;;
  esac
done
# Second, the positional arguments.
shift $(($OPTIND - 1))

# Exact repository slug must be provided on command line.
if [ -z "$1" ]
then
  printf "Usage: <slug> must be provided\n" >&2
  exit 1
else
  SLUG="$(echo "$1" | tr -c -d 'a-z_-')"
  shift 1
fi

# Regex applied to branch names, in POSIX Extended Regular Expression syntax.
# Defaults to the least restrictive, `.*`, matching any branch.
# <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html>
# <https://en.wikipedia.org/wiki/Kleene_star>
if [ -z "$1" ]
then
  REBRANCH_PARTIAL='.*'
else
  REBRANCH_PARTIAL="$1"
fi

# Fail on encountering an undefined variable.
set -u

# The provided ERE is applied to whole lines outputted by jq.
# When the -c option is given, each line contains the branch name followed by
# the its latest commit hash.
# Therefore the ERE is modified by anchoring to the beginning of the line,
# and either anchoring to the end of the line (without -c) or terminating on a
# tab character.
# NOTE: This is not infallible as the user can provide an ERE which passes over
# a tab, though the added terminating tab would not match any line.
# Santitization is not applied to the ERE because it is kept quoted at all
# stages.
if [ -z "${SHOW_COMMIT}" ]
then
  REBRANCH="^${REBRANCH_PARTIAL}\$"
else
  REBRANCH="^${REBRANCH_PARTIAL}\t"
fi

# BitBucket's REST API uses paging.
# NRG_DEPAGE points to a utility which extracts the values into one JSON array,
# i.e. an ordered list of JSON objects.
# <https://www.json.org/json-en.html>
NRG_DEPAGE='_nrg_queryBitBucket__depage.sh'

# Pass the -d option down to `_nrg_queryBitBucket__depage.sh` which uses it in
# the same way.
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

# <https://developer.atlassian.com/server/bitbucket/rest/v810/api-group-repository/#api-api-latest-projects-projectkey-repos-repositoryslug-branches-get>
URI="projects/${PROJECT}/repos/${SLUG}"
if [ -z "${TAG_NOT_BRANCH}" ]
then
  URI="${URI}/branches"
else
  URI="${URI}/tags"
fi

if [ ! -z "${DEBUGMODE}" ]
then
  printf "URI=%s\n" "${URI}" >&2
fi


JQ_QUERY='\(.displayId | select(contains(" ") | not))'
if [ ! -z "${SHOW_COMMIT}" ]
then
  JQ_QUERY="${JQ_QUERY}\\u0009\\(.latestCommit)"
  #                    ^
  #                    |
  # This tab matches the final/terminating tab in REBRANCH.
fi
if [ -z "${TAG_NOT_BRANCH}" ]
then
  JQ_QUERY=".[] | select(.type == \"BRANCH\") | \"${JQ_QUERY}\""
else
  JQ_QUERY=".[] | select(.type == \"TAG\") | \"${JQ_QUERY}\""
fi


if [ ! -z "${DEBUGMODE}" ]
then
  printf "JQ_QUERY=%s\n" "${JQ_QUERY}" >&2
fi


# Use the depager subscript, which puts JSON data on STDOUT as it's received,
# then use `jq` string interpolation to produce one line per branch/tag.
# Those lines are piped into `grep` and filtered using the user-supplied ERE.
# When the -1 option (the number one) is given, the output lines are counted
# using `wc` and exit status is set to non-zero if the number of output lines
# is either zero or more than one.
if [ -z "${EXACTLYONE}" ]
then
  ${NRG_DEPAGE} "${URI}" \
  | jq -r "${JQ_QUERY}" \
  | grep -Ei "${REBRANCH}"
else
  COUNT=$(${NRG_DEPAGE} ${URI} \
  | jq -r "${JQ_QUERY}" \
  | grep -Ei "${REBRANCH}" \
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
