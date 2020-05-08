#Y'UV420p/I420 (and Y'V12 or YV12)
YUV420p=I420
Y'UV420p is a planar format, meaning that the Y', U, and V values are grouped together instead of interspersed. The reason for this is that by grouping the U and V values together, the image becomes much more compressible. When given an array of an image in the Y'UV420p format, all the Y' values come first, followed by all the U values, followed finally by all the V values.

The Y'V12 format is essentially the same as Y'UV420p, but it has the U and V data switched: the Y' values are followed by the V values, with the U values last. As long as care is taken to extract U and V values from the proper locations, both Y'UV420p and Y'V12 can be processed using the same algorithm.
![YUV420p/YV12](https://upload.wikimedia.org/wikipedia/en/thumb/0/0d/Yuv420.svg/1200px-Yuv420.svg.png)
[ref](https://en.wikipedia.org/wiki/YUV)

#Y'UV420sp (NV21)
YUV 4:2:0 planar image, with 8 bit Y samples, followed by interleaved V/U plane with 8bit 2x2 subsampled chroma samples.
![NV12](http://i.stack.imgur.com/2ot7y.png)

# All Planar YUV Formats

Planar YUV Formats | Format descriptions
------------------ | ---------------------
YV12 | 8 bit Y plane followed by 8 bit 2x2 subsampled V and U planes.
I420 | 8 bit Y plane followed by 8 bit 2x2 subsampled U and V planes.
NV12 | 8-bit Y plane followed by an interleaved U/V plane with 2x2 subsampling
NV21 | As NV12 with U and V reversed in the interleaved plane