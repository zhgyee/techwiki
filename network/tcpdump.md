# Introduction #

Add your content here.


# Details #

Add your content here.  Format your content with:
  * Text in **bold** or _italic_
  * Headings, paragraphs, and lists
  * Automatic links to other wiki pages
```
tcpdump -i eth0 -s0 -w /data/netdata.pcap 
adb shell tcpdump -p -s 0 -w /sdcard/capture.pcap
tcpdump -p -s 0 -w /sdcard/capture.pcap
```

再用wireshark查看
# TCP确认是否重传
如果下个ack包的seq number为前一个tcp retransmission包的next sequence number,则说明重传成功。
