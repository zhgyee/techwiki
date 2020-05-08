# Introduction #

Add your content here.


# Details #

# Accept-Ranges #

Accept-Ranges: bytes - The Accept-Ranges header indicate that the server accept range requests for a resource. The unit used by the remote web servers is in bytes. This header tell us that either server support download resume or downloading files in smaller parts simultaneously so that download manager applications can speed up download for you. The Accept-Ranges: none response header indicate that the download is not resumable.

如果http responce没有此字段，则只能从头开始读文件，不能做seek
如何知道服务器是否支持？使用curl:
```
$ curl -I http://s0.cyberciti.org/images/misc/static/2012/11/ifdata-welcome-0.png
```
输出包含如下字段说明可以seek
```
Accept-Ranges: bytes
```

# Content-Range #
The server has fulfilled the partial GET request for the resource.
> The request MUST have included a Range header field (section 14.35)
> indicating the desired range, and MAY have included an If-Range
> header field (section 14.27) to make the request conditional.

http://www.ietf.org/rfc/rfc2616.txt