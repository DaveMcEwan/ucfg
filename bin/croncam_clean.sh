
CRONCAM_SHDIR=$(dirname $0)
. "${CRONCAM_SHDIR}/croncam_common.sh"

# Remove old frames and videos.
find ${CRONCAM_DIR_FRAME} -type f -mtime +${CRONCAM_CLEAN_FRAME_DAYS} -delete
find ${CRONCAM_DIR_VIDEO} -type f -mtime +${CRONCAM_CLEAN_VIDEO_DAYS} -delete

# Remove old frames and videos from backup/intermediate machine.
ssh ${CRONCAM_BK_HOSTNAME} \
  "find ${CRONCAM_BKDIR_FRAME} -type f -mtime +${CRONCAM_BKCLEAN_FRAME_DAYS} -delete"
ssh ${CRONCAM_BK_HOSTNAME} \
  "find ${CRONCAM_BKDIR_VIDEO} -type f -mtime +${CRONCAM_BKCLEAN_VIDEO_DAYS} -delete"
