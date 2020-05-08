
# proxy setting #
```
export http_proxy=http://your.proxy.server:port/
-x, --proxy <[protocol://][user@password]proxyhost[:port]>
```

# http request #
```
curl -I http://s0.cyberciti.org/images/misc/static/2012/11/ifdata-welcome-0.png
curl -i -H "Accept: application/json" -H "Content-Type: application/json" http://hostname/resource
curl -X POST -d @filename http://hostname/resource
```
http://14.22.0.17/6d259cd4e1492d08af8188c68cfc3401_0_10.mp4.ts?k=a2e71b47850c270154e18ae745f77dc8-ee4b-1375951790
http://www.cyberciti.biz/cloud-computing/http-status-code-206-commad-line-test/

# http download
有些需要跳转，所以加-L才能下载
```
 curl -L http://112.50.233.156/88888888/16/20180531/276160147/20-1-4.hls.ts
```