# Difference between CPU time and wall time
CPU time is not wall time (as in a clock on the wall). 

CPU time is the total execution time or runtime for which the CPU was dedicated to a process. 

The CPU must service many processes every second, not just yours, so your process only gets small task slices in between processing other requests. Each of those small task slices is counted toward the total execution time. However, the time in between processing your requests, while the CPU is processing someone else's request, is NOT counted towards your CPU time.

For example, let's run gzip on a 20MB Apache log file and see where the processing time went:
$ time gzip access.log
real 0m2.125s
user 0m1.920s
sys 0m0.170s

This process took 2.125 seconds of wall time ("real"), 1.920 seconds of CPU time ("user"), and 0.170 seconds were spent in kernel mode ("sys"). The remaining 0.035 seconds were time sliced to other processes. (Make note that compressing a file is an intensive process that demands a lot of CPU time from the server.)

real time == wall time
[ref](http://service.futurequest.net/index.php?/Knowledgebase/Article/View/407)