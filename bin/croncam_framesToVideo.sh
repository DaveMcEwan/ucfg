
CRONCAM_SHDIR=$(dirname $0)
source "${CRONCAM_SHDIR}/croncam_common.sh"

# Only frames named with a date before today are used.
#ENDFRAME_EPOCH=$(date -d $(date -d 'today' '+%F') '+%s')
ENDFRAME_EPOCH=$(date -d $(date -d 'tomorrow' '+%F') '+%s') # TODO

TMPDIR_EPOCH="${CRONCAM_DIR}/tmp_videoFramesByEpoch"
TMPDIR_NUMBER="${CRONCAM_DIR}/tmp_videoFramesByNumber"
CLEANUP_CMD="rm -rf ${TMPDIR_EPOCH} ${TMPDIR_NUMBER}"
trap "${CLEANUP_CMD}" EXIT
mkdir -p "${TMPDIR_EPOCH}"

# Copy, or rather softlink, all relevant PNG frames to temporary directory,
# named by seconds since epoch.
for f in `ls ${CRONCAM_DIR_FRAME}/*.png | grep -E ${CRONCAM_DATE_ERE}`; do
  FRAME_DATE=$(echo ${f} | grep -Eo ${CRONCAM_DATE_ERE} | tr 'Thms' ' :: ')
  FRAME_EPOCH=$(date -d "${FRAME_DATE}" "+%s")
  if [ ${FRAME_EPOCH} -lt ${ENDFRAME_EPOCH} ]; then
    ln -fs "${f}" "${TMPDIR_EPOCH}/${FRAME_EPOCH}.png"
  fi
done

VIDEO_BEGINEPOCH=$(ls ${TMPDIR_EPOCH}/*.png | sort | head -n1 | grep -Eo '[[:digit:]]+')
VIDEO_ENDEPOCH=$(ls ${TMPDIR_EPOCH}/*.png | sort -r | head -n1 | grep -Eo '[[:digit:]]+')
VIDEO_BEGINDATE=$(date -d "@${VIDEO_BEGINEPOCH}" "${CRONCAM_DATE_FMT}")
VIDEO_ENDDATE=$(date -d "@${VIDEO_ENDEPOCH}" "${CRONCAM_DATE_FMT}")
VIDEO_FNAME="${CRONCAM_DIR_VIDEO}/croncam_${VIDEO_BEGINDATE}_${VIDEO_ENDDATE}.mkv"

# Copy softlinks to sequential frame numbers.
mkdir -p "${TMPDIR_NUMBER}"
NUM=0
for f in `ls ${TMPDIR_EPOCH}/*.png | sort`; do
  ln -fs "${f}" "${TMPDIR_NUMBER}/${NUM}.png"
  NUM=$((NUM+1))
done

FFMPEG_INPUT_OPTIONS="-r ${CRONCAM_VIDEO_FPS}"
FFMPEG_INPUT_OPTIONS="${FFMPEG_INPUT_OPTIONS} -f image2"
FFMPEG_INPUT_OPTIONS="${FFMPEG_INPUT_OPTIONS} -s ${CRONCAM_VIDEO_RESOLUTION}"
FFMPEG_OUTPUT_OPTIONS="-vcodec libx264"
FFMPEG_OUTPUT_OPTIONS="${FFMPEG_OUTPUT_OPTIONS} -crf 25"
FFMPEG_OUTPUT_OPTIONS="${FFMPEG_OUTPUT_OPTIONS} -pix_fmt yuv420p"
mkdir -p "${CRONCAM_DIR_VIDEO}"
ffmpeg \
  ${FFMPEG_INPUT_OPTIONS} -i "${TMPDIR_NUMBER}/%d.png" \
  ${FFMPEG_OUTPUT_OPTIONS} "${VIDEO_FNAME}" -y

# Copy to backup machine.
ssh "${CRONCAM_BK_HOSTNAME}" "mkdir -p ${CRONCAM_BKDIR_VIDEO}"
scp "${VIDEO_FNAME}" "${CRONCAM_BK_HOSTNAME}:${CRONCAM_BKDIR_VIDEO}/"
