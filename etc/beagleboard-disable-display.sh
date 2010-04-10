#! /bin/sh
### BEGIN INIT INFO
# Provides:          
# Required-Start:    
# Required-Stop:     
# Default-Start:     3 
# Default-Stop:      0 1 2 4 5 6
# Short-Description: Switches off the DVI on Beagleboard to save power
# Description:       
### END INIT INFO

# Author: Tallak Tveide <tallak@tveide.net>
#

# PATH should only include /usr/* if it runs after the mountnfs.sh script

case "$1" in
  start)
    echo "Switching off DVI to save power"
    echo 0 > /sys/devices/platform/omapdss/display0/enabled
    echo 0 > /sys/devices/platform/omapdss/display1/enabled
  ;;
  stop)
    echo "Switching on DVI"
    echo 1 > /sys/devices/platform/omapdss/display0/enabled
    echo 1 > /sys/devices/platform/omapdss/display1/enabled
  ;;
  restart)
    echo "Switching off DVI to save power"
    echo 0 > /sys/devices/platform/omapdss/display0/enabled
    echo 0 > /sys/devices/platform/omapdss/display1/enabled
  ;;
  run)
    echo "Switching on DVI"
    echo 1 > /sys/devices/platform/omapdss/display0/enabled
    echo 1 > /sys/devices/platform/omapdss/display1/enabled
  ;;
  *)
  echo "Usage: $SCRIPTNAME {start|stop|restart|run}" >&2
  exit 3
  ;;
esac
