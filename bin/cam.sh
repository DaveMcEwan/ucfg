
# Use with a crontab something like this:
# * * * * * /home/dm16886/ucfg/cam.sh
# 0 9 * * * ssh snowy 'find cam -type f -mtime +10 -delete'
# 0 9 * * * find /space/cam -type f -mtime +20 -delete

# Capture a single frame from webcam.
FNAME="/space/cam/cam_`date '+%FT%H%M%S'`.png"
ffmpeg -i /dev/video0 -ss 0:0:1 -frames 1 $FNAME -y
scp $FNAME snowy:cam/

# Update SSH config to correct IP address.
IPADDR="`ip addr | grep enp0s31f6 | grep -Po '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+(?=/)'`"
ssh snowy 'cat .ssh/config' | head -n-1 > .snowy_ssh_config
echo "    Hostname $IPADDR" >> .snowy_ssh_config
scp .snowy_ssh_config snowy:.ssh/config
