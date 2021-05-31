
# Update a remote record of this machine's IP address.
#
# Use with a crontab something like this:
# * * * * * /home/dm16886/ucfg/bin/updateIp.sh snowy d

REMOTE_HOSTNAME="$1"

if [ "$2" = "" ]; then
  LOCAL_HOSTNAME="`hostname`"
else
  LOCAL_HOSTNAME="$2"
fi
LOCAL_DATE="`date`"
LOCAL_IPADDR="`ip addr | grep enp0s31f6 | grep -Po '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+(?=/)'`"

echo "${LOCAL_DATE} ${LOCAL_IPADDR}" | ssh ${REMOTE_HOSTNAME} "cat >> ${LOCAL_HOSTNAME}.ipAddr"

#REMOTE_SCRIPT="ucfg/bin/updateSshHostname.sh"
#ssh ${REMOTE_HOSTNAME} "${REMOTE_SCRIPT} ${LOCAL_HOSTNAME} ${LOCAL_IPADDR}"
