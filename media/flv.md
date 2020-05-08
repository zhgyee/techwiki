#CodecPrivateData 
计算 AVCDecoderConfigurationRecord  得到 CodecPrivateData 数据
H.264 视频流的 CodecPrivateData 实际上就是 AVCDecoderConfigurationRecord 中 SequenceParameterSets（SPS）和 PictureParameterSets（PPS）使用 byte[] {00, 00, 01} 连接的字节数组。
注意！FLV 文件中第一个 VIDEOTAG 的 VIDEODATA 的 AVCVIDEOPACKET 的 Data 总是 AVCDecoderConfigurationRecord（在 ISO/IEC 14496-15 中定义），解码的时候注意跳过这个 VIDOETAG。

下面蓝色的部分就是 FLV 文件中的 AVCDecoderConfigurationRecord 部分。
```
00000130h: 00 00 00 17 00 00 00 00 01 4D 40 15 FF E1 00 0A ; .........M@.?. 
00000140h: 67 4D 40 15 96 53 01 00 4A 20 01 00 05 68 E9 23 ; gM@.朣..J ...h? 
00000150h: 88 00 00 00 00 2A 08 00 00 52 00 00 00 00 00 00 ; ?...*...R......
```
根据 AVCDecoderConfigurationRecord 结构的定义：
```
configurationVersion = 01
AVCProfileIndication = 4D
profile_compatibility = 40
AVCLevelIndication = 15
lengthSizeMinusOne = FF <- 非常重要，是 H.264 视频中 NALU 的长度，计算方法是 1 + (lengthSizeMinusOne & 3)
numOfSequenceParameterSets = E1 <- SPS 的个数，计算方法是 numOfSequenceParameterSets & 0x1F
sequenceParameterSetLength = 00 0A <- SPS 的长度
sequenceParameterSetNALUnits = 67 4D 40 15 96 53 01 00 4A 20 <- SPS
numOfPictureParameterSets = 01 <- PPS 的个数
pictureParameterSetLength = 00 05 <- PPS 的长度
pictureParameterSetNALUnits = 68 E9 23 88 00 <- PPS
 ```
因此 CodecPrivateData 的字符串表示就是 000001674D4015965301004A2000000168E9238800

# frame data parse
```
00 00 00 02 09 50 00 00 00 04 28 ee 3c b0
```
00 00 00 02 是NALU 数据的长度，由 lengthSizeMinusOne 决定, 
09 50部分是 NALU 数据。
帧数据需要将多个 NALU 使用 byte[] {00, 00, 01} 连接的字节数组。
如果是第一帧数据，那么前面还要加上 CodecPrivateData 数据。

[h264中avc和flv数据的解析](http://blog.csdn.net/peijiangping1989/article/details/6934312)