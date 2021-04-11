
CRONCAM_SHDIR=$(dirname $0)
source "${CRONCAM_SHDIR}/croncam_common.sh"

# Capture a single frame from webcam.
NOW=$(date ${CRONCAM_DATE_FMT})
FRAME_FNAME="${CRONCAM_DIR_FRAME}/croncam_${NOW}.png"
mkdir -p "${CRONCAM_DIR_FRAME}/"
ffmpeg -i /dev/video0 -ss 0:0:1 -frames 1 "${FRAME_FNAME}" -y

# Copy to backup machine.
# NOTE: If network goes down, then there will be a gap on the backup machine.
# An alternative approach, like rsync, is required if backup is essential.
ssh "${CRONCAM_BK_HOSTNAME}" "mkdir -p ${CRONCAM_BKDIR_FRAME}"
scp "${FRAME_FNAME}" "${CRONCAM_BK_HOSTNAME}:${CRONCAM_BKDIR_FRAME}/"
