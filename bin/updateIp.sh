
# Use with a crontab something like this:
# * * * * * /home/dm16886/ucfg/bin/updateIp.sh

# Update SSH config to correct IP address.
IPADDR="`ip addr | grep enp0s31f6 | grep -Po '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+(?=/)'`"
ssh snowy 'cat .ssh/config' | head -n-1 > .snowy_ssh_config
echo "    Hostname ${IPADDR}" >> .snowy_ssh_config
scp .snowy_ssh_config snowy:.ssh/config
