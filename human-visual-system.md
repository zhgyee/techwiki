# Overview
* visual acuity: 20/20 is ~1 arc min!
* field of view: ~190° monocular, ~120° binocular, ~135° vertical!
* temporal resolution: ~60 Hz (depends on contrast, luminance)!
* dynamic range: instantaneous 6.5 f-stops, adapt to 46.5 f-stops!
* color: everything in CIE xy diagram; distances are ~linear in CIE LAB!
* depth cues in 3D displays: vergence, focus, conflicts, (dis)comfort!
* accommodation range: ~8cm to ∞, degrades with age

# What is the maximum speed that the eye can move?
A saccade is a rapid movement of the eye between fixation points. Saccade speed is determined by the distance between the current gaze and the stimulus. If the stimulus is as far as 50˚ away, then peak saccade velocity can get up to around 900˚/sec. This is important because you want the high resolution layer to be large enough so that the eye can’t move to the lower resolution portion in the time it takes to get the gaze position and render the scene. So if system latency is 20 msec, and assume eye can move at 900˚/sec – eye could move 18˚ in that time, meaning you would want the inner (higheslayer radius to be greater than that – but that is only if the stimulus presented is 50˚ away from current gaze.  [see](http://vrguy.blogspot.kr/2016/04/understanding-foveated-rendering.html)

# Binocular Overlap
Binocular overlap is particularly important for depth perception. [see detail](http://sensics.com/what-is-binocular-overlap-and-why-should-you-care/)

# Binocular rivalry
Consider the a green circle that is shown in the eyepieces. Because of the location of the circle, it will be fully shown in the left eyepiece but cut off in the right eyepiece. In fact, when a person looks through both eyepieces at the same time, that person might notice the leftmost border of the right eye and this might look unusual or distracting. The image in the binocular view continues more to the left, but the right eyepiece no longer shows the object. Some people may find this distracting because of binocular rivalry. Instead of seeing a summation of the two images, our perception switches from one image to the other. If the field of view is larger than in our example, say 100 degrees in each eye, this is less of a problem because the discontinuity of the image is outside the central vision area.

![binocularRivalry](/uploads/379369ef7f31395f0525a5cc6610837e/binocularRivalry.png)


