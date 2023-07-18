#!/usr/bin/env sh
# Dave McEwan 2023-07-13

# Using `_nrg_queryBitBucket_{depage,list_files}.sh`, concatenate the contents
# of files on a remote repository (identified by an exact slug and exact
# commit/ref), whose filepaths match an ERE regex.
#
# Environment variable `$BITBUCKET_CREDENTIALS` must be set.
# E.g: `export BITBUCKET_CREDENTIALS=jdoe:XDc1NTkzYjMyODExOrWcTKpzYujz/b/5cQjezElM6+cI`


# Fail on uncaught non-zero exit code.
set -e

# Debug mode prints messages to STDERR.
DEBUGMODE=

# Ensure that exactly one file path is matched.
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

# Take the `at` parameter from an environment variable, but may be
# overridden by the -c option.
# E.g: `export BITBUCKET_DEFAULTREF=6ab2993362e0e54956d90d44aba64148a068eb0f`
# E.g: `export BITBUCKET_DEFAULTREF=feature/fooBar_HM-1234`
# Default to master.
if [ -z "${BITBUCKET_DEFAULTREF}" ]
then
  REF='master'
else
  REF="$(echo "${BITBUCKET_DEFAULTREF}" | tr -c -d 'A-Za-z0-9/_-')"
fi

# Get the sanitized name of this script, used to print usage message and as a
# template for temporary filenames.
# To aid debugging, the sanitized name is found by calling this script with an
# invalid option, such as -h.
THIS="$(echo "$(basename "$0")" | tr -c -d 'a-z_.')"

# Process the command-line arguments.
# <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/getopts.html>
# First, the optional arguments.
while getopts 'd1p:c:' OPT
do
  case $OPT in
    d)  DEBUGMODE=1;;
    1)  EXACTLYONE=1;;
    p)  PROJECT="$(echo "${OPTARG}" | tr -c -d 'A-Za-z0-9_-')";;
    c)  REF="$OPTARG";;
    ?)  printf "Usage: %s [-d] [-1] [-p <projectKey>] [-c <commit>] <slug> [<ERE>]\n" ${THIS}
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

# Regex applied to paths, in POSIX Extended Regular Expression syntax.
# Defaults to the least restrictive, `.*`, matching any path.
# <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html>
# <https://en.wikipedia.org/wiki/Kleene_star>
if [ -z "$1" ]
then
  REPATH_PARTIAL='.*'
else
  REPATH_PARTIAL="$1"
fi

# Fail on encountering an undefined variable.
set -u

# NRG_LISTFILES points to a utility which prints, one per line, file paths
# which match the provided ERE.
NRG_LISTFILES='_nrg_queryBitBucket_list_files.sh'
if [ ! -z "${DEBUGMODE}" ]
then
  NRG_LISTFILES="${NRG_LISTFILES} -d"
fi
if [ ! -z "${EXACTLYONE}" ]
then
  NRG_LISTFILES="${NRG_LISTFILES} -1"
fi
NRG_LISTFILES="${NRG_LISTFILES} -c ${REF} ${SLUG} '${REPATH_PARTIAL}'"

URI_PREFIX="projects/${PROJECT}/repos/${SLUG}/raw"
if [ ! -z "${DEBUGMODE}" ]
then
  printf "URI_PREFIX=%s\n" "${URI_PREFIX}" >&2
fi

# NRG_LISTFILES points to a utility which prints a file's content to STDOUT.
NRG_RAW='_nrg_queryBitBucket__raw.sh'
if [ ! -z "${DEBUGMODE}" ]
then
  NRG_RAW="${NRG_RAW} -d"
fi

# For each of the file paths returned by the NRG_LISTFILES command, fetch the
# contents and print to STDOUT.
eval " ${NRG_LISTFILES}" | xargs -l -i \
  ${NRG_RAW} ${URI_PREFIX}/{}
