# Introduction #

One piece of evidence against this
theory is that images persist in the visual cortex for around 100ms, which implies
that the 10 FPS (Frames Per Second) is the slowest speed that stroboscopic apparent
motion would work; however, it is also perceived down to 2 FPS. Another
piece of evidence against the persistence of vision is the existence of stroboscopic
apparent motions that cannot be accounted for by it.

FPS  | Occurrence
-----|----------------
2 | Stroboscopic apparent motion starts
10 | Ability to distinguish individual frames is lost
16 | Old home movies; early silent films
24 | Hollywood classic standard
25 | PAL television before interlacing
30 | NTSC television before interlacing
48 | Two-blade shutter; proposed new Hollywood standard
50 | Interlaced PAL television
60 | Interlaced NTSC television; perceived flicker in some displays
72 | Three-blade shutter; minimum CRT refresh rate for comfort
90 | Modern VR headsets; no more discomfort from flicker
1000 | Ability to see zipper effect for fast, blinking LED
5000 |Cannot perceive zipper effect


# ffmpeg frame rate #

There are three different time bases for time stamps in FFmpeg. The
values printed are actually reciprocals of these, i.e. 1/tbr, 1/tbn and
1/tbc.

tbn is the time base in AVStream that has come from the container, I
think. It is used for all AVStream time stamps.

tbc is the time base in AVCodecContext for the codec used for a
particular stream. It is used for all AVCodecContext and related time
stamps.

tbr is guessed from the video stream and is the value users want to see
when they look for the video frame rate, except sometimes it is twice
what one would expect because of field rate versus frame rate.