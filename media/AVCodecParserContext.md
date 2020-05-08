# Introduction #

In order to demux raw data you need to parse the raw bistream and extract two kind of information: the frame data and the codec extradata. We name those two activities parse and split. parse is used to reconstruct precisely one frame from raw packets, split is used for extracting extradata from the same stream.


# Details #


parser 的最主要的结构，它类同AVFormatContext ，一个用于parser，一个用于format,
priv\_data 用于特定编码的结构如ParseContext ,如果是h264 parser使用的是H264Context,这些结构
在ff\_xxx\_find\_frame\_end 会使用，而parser主要是通过ff\_xxx\_find\_frame\_end 此类函数解析出一个完整的帧，AVCodecParser 则类同于AVInputFormat,它用来实现特定parser的函数的统一调用接口，
ParseContext  是用来存放parser过程中的状态和数据,主要是给ff\_xxx\_find\_frame\_end 和ff\_combine\_frame 这两函数使用.

# Reference #
How to use demuxer with raw data http://wiki.multimedia.cx/index.php?title=Libav_technical&redirect=no