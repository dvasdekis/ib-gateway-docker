#!/bin/sh

sed -i "s/READ_ONLY_API/$READ_ONLY_API/g" /root/IBController/IBController.ini

/usr/bin/supervisord -c /root/supervisord.conf
