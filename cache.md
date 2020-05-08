# Slots
A slot consists of the following:

* V the valid bit, indicating whether the slot holds valid data. If V = 1, then the data is valid. If V = 0, the data is not valid. Initially, it's invalid. Once data is placed into the slot, it's valid.
* D the dirty bit. This bit only has meaning if V = 1. This indicates that the data in the slot (to be discussed momentarily) has been modified (written to) or not. If D = 1, the data has been modified since being in the cache. If D = 0, then the data is the same as it was when it first entered the cache.
* Tag The tag represents the upper bits of the address. The size of the tag is 32 - lg N where N is the number of bytes in the data part of the slot.
* Cache Line This is the actual data itself. There are N bytes, where N is a power of 2. We will also call this the data block.

![](https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Memory/Figs/slot.png)

# Fully Associative Cache
In a fully associative scheme, any slot can store the cache line. The hardware for finding whether the desired data is in the cache requires comparing the tag bits of the address to the tag bits of every slot (in parallel), and making sure the valid bit is set.

![FAC](https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Memory/Figs/fully.png)

# Direct Mapped Cache
A direct-mapped cache scheme makes picking the slot very simple. It treats the slot as a large array, and the index of the array is picked from bits of the address (which is why we need the number of slots to be a power of 2---otherwise we can't select bits from the address)
The scheme can suffer from many addresses "colliding" to the same slot, thus causing the cache line to be repeatedly evicted, even though there may be empty slots that aren't being used, or being used with less frequency.

![DMC](https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Memory/Figs/direct.png)

# Set Associative Cache
A set-associative scheme is a hybrid between a fully associative cache, and direct mapped cache. It's considered a reasonable compromise between the complex hardware needed for fully associative caches (which requires parallel searches of all slots), and the simplistic direct-mapped scheme, which may cause collisions of addresses to the same slot (similar to collisions in a hash table).

![SAC](https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Memory/Figs/set.png)

# reference
https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/
