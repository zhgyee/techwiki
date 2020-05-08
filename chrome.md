#chrome
## chrome trace
1. start up chrome with below commandline
`google-chrome --enable-impl-side-painting --enable-skia-benchmarking`
`google-chrome --enable-threaded-compositing --force-compositing-mode --enable-impl-side-painting --enable-skia-benchmarking --allow-webui-compositing`
2. goto follow URL
`chrome://inspect/?trace`
##  Rendering steps
1.   Parsing, which turns a chunk of HTML into DOM nodes

2.   Style, which resolves CSS on the DOM

3.   Layout, which figures out where DOM elements end up relative to one another

4.    Paint setup, sometimes referred to as recording, which converts styled DOM elements into a display list (SkPicture) of drawing commands to paint later, on a per-layer basis

5.    Painting, which converts the SkPicture of drawing commands into pixels in a bitmap somewhere (either in system memory or on the GPU if using Ganesh)

6.    Compositing, which assembles all layers into a final screen image

7.    and, less obviously, the presentation infrastructure responsible for actually pushing a new frame to the OS (i.e. the browser UI and its compositor, the GPU process which actually communicates with the GL driver, etc).

https://sites.google.com/a/chromium.org/dev/developers/how-tos/trace-event-profiling-tool/using-frameviewer

