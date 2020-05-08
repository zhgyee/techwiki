# POLLIN and POLLPRI 
There are some description on poll() document.

POLLIN There is data to read. POLLPRI There is urgent data to read.

If you use POLLIN only, poll() will return if there is data or urgent data to read. If you use POLLPRI only, poll() will return only if there is urgent data to read, but ignore normal data.

What's urgent data? Like tcp's out-of-band data. In TCP frame header, there is a flag named urg_data. Urg_data means this frame has higher priority to delivery. Once kernel received a urg_data maked frame, it set a POLLPRI flag! Look at the following code:
```
...
if (tp->urg_data & TCP_URG_VALID)
   mask |= POLLPRI;
....
return mask;
```