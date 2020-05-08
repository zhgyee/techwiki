# downsample
When downscaling by a factor greater than 2, linear filtering leads to aliasing artifacts due to high-frequency components of the source image leaking into the downsampled version.
This problem is commonly dealt with in image processing by widening the filter kernel so that its width is equal to the size of the downscaled pixel. So for instance if downscaling from 100×100 to 25×25, the filter kernel would be greater than or equal in width to a 4×4 square of pixels in the original image. Unfortunately widening the filter kernel isn’t usually a suitable option for realtime rendering, since the number of memory accesses increases with O(N2) as the filter width increases. Because of this a technique known as mipmapping is used instead.

 As any graphics programmer should already know, mipmaps consist of a series of prefiltered versions of a 2D texture that were downsampled with a kernel that’s sufficiently wide enough to prevent aliasing. Typically these downsampled versions are generated for dimensions that are powers of two, so that each successive mipmap is half the width and height of the previous mipmap. 

# OVERSAMPLING AND SUPERSAMPLING

# ref
* https://mynameismjp.wordpress.com/2012/10/24/msaa-overview/
