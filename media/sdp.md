SDP: Session Description Protocol(会话描述协议)(RFC2327)

SDP的目的就是在媒体会话中，传递媒体流信息，允许会话描述的接收者去参与会话。 SDP定义了绘画描述的统一格式,但并不定义多播地址的分配和SDP消息的传输,也不支持媒体编码方案的协商,这些功能均由下层传送协议完成.
典型的会话传送协议包括:SAP(Session Announcement Protocol 会话公告协议),SIP,RTSP,HTTP,和使用MIME的E-Mail.(注意:对SAP只能包含一个会话描述,其它会话传诵协议的SDP可包含多 个绘画描述)
SDP包括以下一些方面：
1） 会话的名称和目的
2） 会话存活时间
3） 包含在会话中的媒体信息，包括：
* 媒体类型(video, audio, etc)
* 传输协议(RTP/UDP/IP, H.320, etc)
* 媒体格式(H.261 video, MPEG video, etc)
* 多播或远端（单播）地址和端口
4） 为接收媒体而需的信息(addresses, ports, formats and so on)
5） 使用的带宽信息
6） 可信赖的接洽信息（Contact information）
协议格式
SDP协议格式必须字段为vostm：
V=(version)
O=(owner/creator and session identifier)
S=(session)
T=(time)
M=(media)
其他可选的描述性字段如下，主要用来扩展VOSTM。
I=(info)
U=(URI)
E=(email)
P=(phone)
C=(connection)
B=(bandwidth)
K=(encryption key)
Z=(time zone)
R=(repeat times)
A=(attr)
SDP格式实例：
Session description
 v=  (protocol version)
 o=  (owner/creator and session identifier)
 s=  (session name)
 i=* (session information)
 u=* (URI of description)
 e=* (email address)
 p=* (phone number)
 c=* (connection information - not required if included in all media)
 b=* (zero or more bandwidth information lines)
 One or more time descriptions ("t=" and "r=" lines, see below)
 z=* (time zone adjustments)
 k=* (encryption key)
 a=* (zero or more session attribute lines)
 Zero or more media descriptions
Time description
 t=  (time the session is active)
 r=* (zero or more repeat times)
Media description, if present
 m=  (media name and transport address)
 i=* (media title)
 c=* (connection information - optional if included at
      session-level)
 b=* (zero or more bandwidth information lines)
 k=* (encryption key)
 a=* (zero or more media attribute lines)
以上带"*"号的是可选的,其余的是必须的。一般顺序也按照上面的顺序来排列。
a=*是sdp协议扩展属性定义，除上面以外的，分解时其它的都可以扔掉。
a=charset属性指定协议使用的字符集。一般的是ISO-10646。
#attr control
From RFC 2326:
----------------------------------------
C.1.1 Control URL

The "a=control:" attribute is used to convey the control URL. This
attribute is used both for the session and media descriptions. If
used for individual media, it indicates the URL to be used for
controlling that particular media stream. If found at the session
level, the attribute indicates the URL for aggregate control.

Example:
a=control:rtsp://example.com/foo

This attribute may contain either relative and absolute URLs,
following the rules and conventions set out in RFC 1808 [25].
Implementations should look for a base URL in the following order:

1. The RTSP Content-Base field
2. The RTSP Content-Location field
3. The RTSP request URL

If this attribute contains only an asterisk (*), then the URL is
treated as if it were an empty embedded URL, and thus inherits the
entire base URL.
[ref](http://osdir.com/ml/ietf.mmusic/2002-09/msg00006.html)

#a=imageattr
```
a=imageattr:104 recv [x=[128:16:352],y=[96:16:288]] send [x=[128:16:352],y=[96:16:288]]
a=fmtp:104 profile-level-id=42800d;max-mbps=11880;max-fs=396; impl=FFMPEG
a=rtpmap:100 VP8/90000
a=imageattr:100 recv [x=[128:16:352],y=[96:16:288]] send [x=[128:16:352],y=[96:16:288]]

```
imageattr表示发送方和接收方或以采用的分辨率范围。
 The x-axis resolution can take the values 128 to 352 in 16 pixels
 steps and 96 to 288 in 16 pixels steps.
#rtp端口号
m=video 12310 RTP/AVP 100