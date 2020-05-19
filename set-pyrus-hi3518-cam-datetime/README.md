# set-pyrus-hi3518-cam-datetime

I have a Pyrus-branded outdoor IP camera, marked with the model WST-8102-TD.

It's a bit crap, and its web UI is awful and plain doesn't work for me.

I can't set the date & time that it overlays on the video feed to be correct
via the broken web interface.

I can, however, telnet to it using its default, hardcoded credentials -
username `root`, password `xmhdipc`, and execute the date command.

So, in this dir is a shell script which uses `expect` to log in via telnet
and set the camera's date & time to the current date & time, so I can run
it regularly via cron to keep the camera's time correct.

## RTSP URL

Whilst it's not directly related to this script, if you find this documentation
by Googling for this camera, the RTSP URL which works for me for it is:

rtsp://pyruscam/user=admin&password=&channel=&stream=.sdp?real_stream--rtp-caching=100
(yes, empty password; if you put the actual password in, it doesn't work!)

Gets me a reasonable 1920x1080 20fps stream in H264 - MPEG-4 AVC (part 10),
bitrate arond 5000kbps.

