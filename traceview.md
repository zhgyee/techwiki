#timeline meaning
* Incl CPU time is the inclusive cpu time. It is the sum of the time spent in the function itself, as well as the sum of the times of all functions that it calls.
* Excl CPU time is the exclusive cpu time. It is only the time spent in the function itself. You'll notice that it is always the same as the "incl time" of the "self" child.
* CPU time is the time that the function is actually running (this would not include waiting on IO) and the real time is the wall clock time (which would include time spent doing IO).