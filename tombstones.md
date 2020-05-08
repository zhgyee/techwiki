#The tombstone inform you about:

Build fingerprint
Crashed process and PIDs
Terminated signal and fault address
CPU registers
Call stack
Stack content of each call

## Using ndk-stack
```
./ndk-stack -sym ~/myrelease/symbols -dump ~/win/bytesthink/Documents/test/perform_releases/tombstone_01
```

## Using the addr2line
```
addr2line -f -e ~/myrelease/symbols/system/lib/libmytestt.so 00003a93
```

#renderence
http://bytesthink.com/blog/?p=133
