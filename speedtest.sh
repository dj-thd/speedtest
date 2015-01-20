#!/bin/bash

function measurespeed {
	bytes_start=`cat /sys/class/net/eth0/statistics/rx_bytes`
	#time_start=`date +%s`
	sleep 1
	#time_end=`date +%s`
	bytes_end=`cat /sys/class/net/eth0/statistics/rx_bytes`

	#echo "($bytes_end-$bytes_start)/($time_end-$time_start)" | bc
	echo "$bytes_end-$bytes_start" | bc
}

# Use ubuntu and debian ISO repositories to test download speed (change this in future!)
wget -O - http://releases.ubuntu.com/raring/ubuntu-13.04-server-amd64.iso >/dev/null 2>/dev/null &
wget -O - http://cdimage.debian.org/debian-cd/7.8.0/amd64/iso-dvd/debian-7.8.0-amd64-DVD-1.iso >/dev/null 2>/dev/null &
wget -O - http://cdimage.debian.org/debian-cd/7.8.0/amd64/iso-dvd/debian-7.8.0-amd64-DVD-2.iso >/dev/null 2>/dev/null &
wget -O - http://cdimage.debian.org/debian-cd/7.8.0/amd64/iso-dvd/debian-7.8.0-amd64-DVD-3.iso >/dev/null 2>/dev/null &

sleep 2

maxspeed=0
minspeed=9999999999999999	# TODO: Quick fix

bytes_all_start=`cat /sys/class/net/eth0/statistics/rx_bytes`
time_all_start=`date +%s`
for i in {1..15}; do
	currentspeed=`measurespeed`
	if [ "$currentspeed" -gt "$maxspeed" ]; then
		maxspeed="$currentspeed"
	fi
	if [ "$currentspeed" -lt "$minspeed" ]; then
		minspeed="$currentspeed"
	fi
	speed_mb=$(echo "scale=2;($currentspeed*8)/1000000" | bc)
	echo "Instant download rate: $speed_mb Mbit/s"
done
time_all_end=`date +%s`
bytes_all_end=`cat /sys/class/net/eth0/statistics/rx_bytes`

min_speed_mb=$(echo "scale=2;($minspeed*8)/1000000" | bc)
max_speed_mb=$(echo "scale=2;($maxspeed*8)/1000000" | bc)
mean_speed_mb=$(echo "scale=2;((($bytes_all_end-$bytes_all_start)/($time_all_end-$time_all_start))*8)/1000000" | bc)

echo "*************"

kill $(jobs -p)

echo "Minimum rate: $min_speed_mb Mbit/s"
echo "Maximum peak rate: $max_speed_mb Mbit/s"
echo "Mean download rate: $mean_speed_mb Mbit/s"
