#Changing the stream transport protocol

To switch VLC from HTTP streaming to RTP/RTSP streaming:

* On the VLC media player Tools menu, click Preferences.

* In the Simple Preferences dialog box, click Input / Codecs in the contents panel.

* In Input & Codecs Settings, in the Network area, change the Live555 stream transport option from HTTP (default) to RTP over RTSP (TCP).

Click Save.

# Starting stream playback

By default, VLC media player is configured with a very small caching buffer. This can lead to choppy playback initially but it will eventually smooth out over time as VLC automatically increases the size of this buffer. The steps below explain how to change the default cache size before connecting to the stream. 

To set the default cache size and play a live or on demand stream:

* On the VLC media player Media menu, click Open Network Stream.

* At the bottom of the Open Media dialog box, select the Show more options check box.

* Set the Caching value to a higher value such as 1200 ms. This value is retained between VLC media player playback sessions and restarts.

* Enter the URL of the stream that you want to play in the Please enter a network URL field and then click Play. 

The examples below show possible stream URLs for each type of application:

VOD

rtsp://[wowza-ip-address]:1935/vod/mp4:sample.mp4

Live

rtsp://[wowza-ip-address]:1935/live/myStream.stream

Where [wowza-ip-address] is the IP address or domain name of the Wowza media server.