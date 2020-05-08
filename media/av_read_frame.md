# Introduction #

读出一帧数据：
  1. 一帧视频
  1. 几帧音频
    1. 固定码率，几帧音频
    1. 可变码率， 一帧音频


# 实现 #
  1. 调用[read\_frame\_internal](read_frame_internal.md)来读数据
  1. 读到数据后，如果需要解析PTS，则分析PTS
  1. 调用parse组帧