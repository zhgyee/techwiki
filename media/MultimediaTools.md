# Introduction #

Add your content here.

# asf #
[asf2vc1 ](http://www.ftyps.com/unrelated/asf2vc1/)

[asfview](asfview.md)
查看asf/wmv文件信息

# Elecard StreamAnalyzer #

Elecard StreamAnalyzer能够分辨出视频流中的IPB帧，同时能够解析出其中的语义元素值，这在解析码流的过程中十分重要。但是需要注意的是，有时候会出现视频流在进行容器打包的时候，有些信息出现了错误。所以对于解析视频流文件的相关语义信息，最好的方式是先提取视频流中的ES流，然后再使用Elecard StreamAnalyzer进行语义解析。需要注意的是，在播放ES流的时候，需要修改
文件的扩展名。

# Elecard StreamEye #

Elecard StreamEye与Elecard StreamAnalyzer的使用场景相似。但是较Elecard StreamAnalyzer 来说，Elecard StreamEye是以图表的方式来显示，更加的直观，并且它可以显示每帧图像的大小，还可以以显示顺序与解码顺序分别显示每帧图像的顺序。但是Elecard StreamEye在使用的过程中，也要注意与Elecard StreamAnalyzer同样的问题。即在使用时，最好是在抽取视频的ES流之后再来使用，得到的信息会比较准确。还需要注意的是，在播放ES流的时候，需要修改
文件的扩展名。

# Elecard BufferAnalyzer #

可以查看视频文件大小以及每帧图像的PTS。

# MPEG-2 TS packet analyser #

用来分析MPEG的TS流。可以提取ts流中的PID值并且显示不同pid的packet内容。

# tsMuxer #

从ts中解复用出视频es流和音频流。还可以按要求切割出需要的部分视频。

# Vega #

可以查看es流和H264、mpeg视频的信息，包括语义信息，码流内容等。