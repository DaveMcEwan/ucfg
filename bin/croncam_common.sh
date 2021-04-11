
# Use with a crontab something like this:
# * * * * * /home/dm16886/ucfg/bin/croncam_captureFrame.sh
# 0 1 * * * /home/dm16886/ucfg/bin/croncam_framesToVideo.sh
# 0 6 * * * /home/dm16886/ucfg/bin/croncam_clean.sh

CRONCAM_DIR="/space/croncam"
CRONCAM_DIR_FRAME="${CRONCAM_DIR}/frame"
CRONCAM_DIR_VIDEO="${CRONCAM_DIR}/video"

CRONCAM_BK_HOSTNAME="snowy"

# Remote structure mirrors local structure by default.
CRONCAM_BKDIR=$(basename "${CRONCAM_DIR}")
CRONCAM_BKDIR_FRAME="${CRONCAM_BKDIR}/"$(basename "${CRONCAM_DIR_FRAME}")
CRONCAM_BKDIR_VIDEO="${CRONCAM_BKDIR}/"$(basename "${CRONCAM_DIR_VIDEO}")

CRONCAM_DATE_FMT="+%FT%Hh%Mm%Ss"
CRONCAM_DATE_ERE="[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}T[[:digit:]]{2}h[[:digit:]]{2}m[[:digit:]]{2}s"

CRONCAM_FILTER_DATE="grep -Eo ${CRONCAM_DATE_ERE} | tr 'Thms' ' :: '"

CRONCAM_CLEAN_FRAME_DAYS=5    # NOTE: Videos are this many days/minutes long.
CRONCAM_CLEAN_VIDEO_DAYS=20
CRONCAM_BKCLEAN_FRAME_DAYS=2
CRONCAM_BKCLEAN_VIDEO_DAYS=6

# Native resolution of captures should be matched. (mine is 640x480)
CRONCAM_VIDEO_RESOLUTION="640x480"

# Resulting video should play at a rate of 1day:1minute, 24 frames per second.
CRONCAM_VIDEO_FPS=24

