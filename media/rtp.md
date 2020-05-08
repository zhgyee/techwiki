
#RTP header structure
```
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |V=2|P|X|  CC   |M|     PT      |       sequence number         |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                           timestamp                           |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |           synchronization source (SSRC) identifier            |
   +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
   |            contributing source (CSRC) identifiers             |
   |                             ....                              |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```
rtp cb, seq num:45689, payload type:100, ssrc:0xa429e1e6
rtp cb, data:0x80 0x64 0xb2 0x79 0x48 0x5f 0x8a 0x1c 0xa4 0x29 0xe1 0xe6
#RTP包
RTP标题由4个信息包标题域和其他域组成：有效载荷类型(payload type)域，顺序号(sequence number)域，时间戳(timestamp)域和同步源标识符(Synchronization Source Identifier)域等.
## SSRC
同步源标识符(Synchronization Source Identifier，SSRC)域的长度为32位。它用来标识RTP信息包流的起源，在RTP会话或者期间的每个信息包流都有一个清楚的SSRC。SSRC不是发送端的IP地址，而是在新的信息包流开始时源端随机分配的一个号码
#wireshark设置
## 设置rtp playload类型h.264 decode
found playload type in rtp packet:Payload type: DynamicRTP-Type-96 (96)
set:edit->preference->protocol->h.264-->payloads type = 96
## tshark extract payload
`tshark -nr capture_ok.cap -R rtp -R 'rtp.ssrc==0x2C53' -T fields -e rtp.payload -w video.h264 `

