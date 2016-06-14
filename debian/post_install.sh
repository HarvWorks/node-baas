#!/bin/bash

# Postinst script for baas package

NAME="baas"
file_default="/etc/default/${NAME}_defaults"
file_init="/etc/init/$NAME.conf"

if [ -e $file_default ]; then newhash_file_default=$(md5sum < $file_default); fi
if [ -e $file_default.postinst ]; then oldhash_file_default=$(md5sum < $file_default.postinst); fi
if [ -e $file_init ]; then newhash_file_init=$(md5sum < $file_init); fi
if [ -e $file_init.postinst ]; then oldhash_file_init=$(md5sum < $file_init.postinst); fi

# Check if one of the files changed. If so, restart; if not, reload
if [ -e $file_default.postinst ] && [ -e $file_init.postinst ]
then
	if [ "$newhash_file_default" != "$oldhash_file_default" ] || [ "$newhash_file_init" != "$oldhash_file_init" ]
	then
		echo "Init or default file changed, restarting"
		service $NAME stop || true
		service $NAME start
	else
		echo "Reloading"
		service $NAME reload || service $NAME restart
	fi
else
	echo "Restarting"
	service $NAME stop || true
	service $NAME start
fi

# Delete the files if they exists
rm $file_default.postinst $file_init.postinst 2> /dev/null || true

if [ -f /etc/cron.daily/logrotate ] 
then
	mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate
fi
	
# Copy logrotate script
cp /opt/auth0/$NAME/debian/$NAME-logs /etc/logrotate.d/

